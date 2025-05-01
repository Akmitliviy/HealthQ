using System.Text.Json;
using Bogus;
using HealthQ_API.Context;
using HealthQ_API.Entities;
using HealthQ_API.Entities.Auxiliary;
using Hl7.Fhir.Model;
using Hl7.Fhir.Serialization;
using Hl7.Fhir.Specification.Snapshot;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HealthQ_API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class PopulateController : BaseController
{
    private readonly HealthqDbContext _context;
    private readonly int _numberOfUsers = 200;
    private readonly int _numberOfDoctors = 20;
    private readonly int _numberOfAdministrators = 5;
    private readonly int _numberOfQuestionnaires = 600;
    private readonly int _numberOfTemplates = 300;

    public PopulateController(HealthqDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public Task<ActionResult> PopulateAsync(CancellationToken ct) =>
        ExecuteSafely(async () =>
        {
        var userFaker = new Faker<UserModel>()
            .RuleFor(u => u.Email, f => f.Internet.Email())
            .RuleFor(u => u.Username, f => f.Internet.UserName())
            .RuleFor(u => u.PasswordSalt, _ => "NRwoWolpjmQs8bBJXQt7JA==")
            .RuleFor(u => u.PasswordHash, _ => "mwxRmeGAhN0FtZf54N+r5vI+n3qx7oPlOfeZoq5nfN0=") // Password: 123456
            .RuleFor(u => u.FirstName, f => f.Name.FirstName())
            .RuleFor(u => u.LastName, f => f.Name.LastName())
            .RuleFor(u => u.BirthDate, f => DateOnly.FromDateTime(f.Date.Past(30)))
            .RuleFor(u => u.Gender, f => f.PickRandom<EGender>())
            .RuleFor(u => u.PhoneNumber, f => f.Phone.PhoneNumber("+###########"))
            .RuleFor(u => u.UserType, _ => EUserType.Patient);

        var users = userFaker.Generate(_numberOfUsers);
        
        for(var i = 0; i < _numberOfDoctors; i++)
            users[i].UserType = EUserType.Doctor;
        
        for(var i = 0; i < _numberOfAdministrators; i++)
            users[i].UserType = EUserType.Administrator;
        
        await _context.Users.AddRangeAsync(users, ct);
        await _context.SaveChangesAsync(ct);

        var doctorUsers = users.Where(u => u.UserType == EUserType.Doctor).ToList();
        var patientUsers = users.Where(u => u.UserType == EUserType.Patient).ToList();

        var doctors = doctorUsers.Select(u => new DoctorModel { UserEmail = u.Email }).ToList();
        var patients = patientUsers.Select(u => new PatientModel { UserEmail = u.Email }).ToList();

        await _context.Doctors.AddRangeAsync(doctors, ct);
        await _context.Patients.AddRangeAsync(patients, ct);
        await _context.SaveChangesAsync(ct);

        var serializer = new FhirJsonSerializer();

        var itemIds = new List<string>();
        
        var id = Guid.NewGuid();
        
        string publisherEmailGlobal = "";
        var templateFaker = new Faker<TemplateModel>()
            .RuleFor(q => q.Id, _ => id)
            .RuleFor(q => q.QuestionnaireContent, faker =>
            {
                var itemId = faker.Random.Guid().ToString();
                itemIds.Add(itemId);

                var publisherEmail = faker.PickRandom(doctors).UserEmail;
                publisherEmailGlobal = publisherEmail;

                var questionnaire = new Questionnaire
                {
                    Id = id.ToString(),
                    Title = faker.Lorem.Sentence(3),
                    Status = PublicationStatus.Draft,
                    Date = DateTime.UtcNow.ToString("s") + "Z",
                    Publisher = publisherEmail,
                    Description = faker.Lorem.Sentence(6),
                    Purpose = "Pre surgery",
                    EffectivePeriod = new Period
                    {
                        Start = DateTime.UtcNow.ToString("o"),
                        End = DateTime.UtcNow.AddHours(6).ToString("o")
                    },
                    Item = new List<Questionnaire.ItemComponent>
                    {
                        new Questionnaire.ItemComponent
                        {
                            ElementId = itemId,
                            Extension = new List<Extension>
                            {
                                new Extension("question-type", new FhirString("OneChoice"))
                            },
                            ModifierExtension = new List<Extension>(),
                            LinkId = itemId,
                            Definition = "",
                            Code = new List<Coding>(),
                            Prefix = "",
                            Text = faker.Lorem.Sentence(4),
                            Type = Questionnaire.QuestionnaireItemType.Question,
                            EnableWhen = new List<Questionnaire.EnableWhenComponent>(),
                            Required = true,
                            AnswerOption = new List<Questionnaire.AnswerOptionComponent>
                            {
                                new Questionnaire.AnswerOptionComponent
                                    { Value = new FhirString(faker.Lorem.Word()) },
                                new Questionnaire.AnswerOptionComponent
                                    { Value = new FhirString(faker.Lorem.Word()) }
                            },
                            Item = new List<Questionnaire.ItemComponent>()
                        }
                    },
                    Extension = new List<Extension>()
                };
                
                id = Guid.NewGuid();
                
                return serializer.SerializeToString(questionnaire);
            })
            .RuleFor(q => q.OwnerId, _ =>
            {
                var publisherEmail = publisherEmailGlobal;
                publisherEmailGlobal = "";
                return publisherEmail;
            });

        var templates = templateFaker.Generate(_numberOfTemplates);
        await _context.Templates.AddRangeAsync(templates, ct);
        await _context.SaveChangesAsync(ct);
        
        var questionnaireFaker = new Faker<QuestionnaireModel>()
            .RuleFor(q => q.Id, _ => id)
            .RuleFor(q => q.QuestionnaireContent, faker =>
            {
                var itemId = faker.PickRandom(itemIds);

                var publisherEmail = faker.PickRandom(doctors).UserEmail;
                publisherEmailGlobal = publisherEmail;

                var questionnaire = new Questionnaire
                {
                    Id = id.ToString(),
                    Title = faker.Lorem.Sentence(3),
                    Status = PublicationStatus.Active, // for QuestionnaireModel table
                    Date = DateTime.UtcNow.ToString("s") + "Z",
                    Publisher = publisherEmail,
                    Description = faker.Lorem.Sentence(6),
                    Purpose = "Pre surgery",
                    EffectivePeriod = new Period
                    {
                        Start = DateTime.UtcNow.ToString("o"),
                        End = DateTime.UtcNow.AddHours(6).ToString("o")
                    },
                    Item = new List<Questionnaire.ItemComponent>
                    {
                        new Questionnaire.ItemComponent
                        {
                            ElementId = itemId,
                            Extension = new List<Extension>
                            {
                                new Extension("question-type", new FhirString("OneChoice"))
                            },
                            ModifierExtension = new List<Extension>(),
                            LinkId = itemId,
                            Definition = "",
                            Code = new List<Coding>(),
                            Prefix = "",
                            Text = faker.Lorem.Sentence(4),
                            Type = Questionnaire.QuestionnaireItemType.Question,
                            EnableWhen = new List<Questionnaire.EnableWhenComponent>(),
                            Required = true,
                            AnswerOption = new List<Questionnaire.AnswerOptionComponent>
                            {
                                new Questionnaire.AnswerOptionComponent
                                    { Value = new FhirString(faker.Lorem.Word()) },
                                new Questionnaire.AnswerOptionComponent
                                    { Value = new FhirString(faker.Lorem.Word()) }
                            },
                            Item = new List<Questionnaire.ItemComponent>()
                        }
                    },
                    Extension = new List<Extension>()
                };
                
                id = Guid.NewGuid();
                
                return serializer.SerializeToString(questionnaire);
            })
            .RuleFor(q => q.OwnerId, _ =>
            {
                var publisherEmail = publisherEmailGlobal;
                publisherEmailGlobal = "";
                return publisherEmail;
            });
        
        var questionnaires = questionnaireFaker.Generate(_numberOfQuestionnaires);
        await _context.Questionnaires.AddRangeAsync(questionnaires, ct);
        await _context.SaveChangesAsync(ct);

        var fileFaker = new Faker<FileModel>()
            .RuleFor(fm => fm.FileName, f => f.System.FileName())
            .RuleFor(fm => fm.FileData, f => f.Random.Bytes(100))
            .RuleFor(fm => fm.ContentType, f => "application/pdf");

        var files = fileFaker.Generate(10);
        await _context.Files.AddRangeAsync(files, ct);
        await _context.SaveChangesAsync(ct);

        var doctorPatientsFaker = new Faker<DoctorPatient>()
            .RuleFor(dp => dp.PatientId, f => f.PickRandom(users.Where(u => u.UserType == EUserType.Patient)).Email)
            .RuleFor(dp => dp.DoctorId, f => f.PickRandom(users.Where(u => u.UserType == EUserType.Doctor)).Email);

        var doctorPatients = new List<DoctorPatient>();
        var faker = new Faker();
        foreach (var patient in patients)
        {
            var doctorEmail = faker.PickRandom(doctors).UserEmail;
            doctorPatients.Add(new DoctorPatient
            {
                PatientId = patient.UserEmail,
                DoctorId = doctorEmail,
                Patient = patient,
                Doctor = doctors.Find(d => d.UserEmail == doctorEmail)!
            });
        }
        
        await _context.DoctorPatients.AddRangeAsync(doctorPatients, ct);
        await _context.SaveChangesAsync(ct);
        
        var patientQuestionnaires = new List<PatientQuestionnaire>();
        foreach (var questionnaire in questionnaires)
        {
            var patient = faker.PickRandom(doctorPatients.Where(dp => dp.DoctorId == questionnaire.OwnerId).Select(dp => dp.Patient).ToList());
            
            patientQuestionnaires.Add(new PatientQuestionnaire
            {
                PatientId = patient.UserEmail,
                QuestionnaireId = questionnaire.Id,
                Patient = patient,
                Questionnaire = questionnaire
                
            });
        }
        await _context.PatientQuestionnaire.AddRangeAsync(patientQuestionnaires, ct);
        await _context.SaveChangesAsync(ct);

        return Ok("Database populated successfully!");
    });
}
