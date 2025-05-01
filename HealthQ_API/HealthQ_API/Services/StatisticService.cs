using System.Text;
using HealthQ_API.Repositories;
using HealthQ_API.Repositories.Interfaces;
using Hl7.Fhir.Serialization;
using Questionnaire = Hl7.Fhir.Model.Questionnaire;

namespace HealthQ_API.Services;

public class StatisticService
{
    private readonly IQuestionnaireRepository _questionnaireRepository;
    private readonly IUserRepository _userRepository;

    public StatisticService(
        IQuestionnaireRepository questionnaireRepository,
        IUserRepository userRepository)
    {
        _questionnaireRepository = questionnaireRepository;
        _userRepository = userRepository;
    }

    public async Task<(byte[], string, string)> GetQuestionnaireReportAsync(string doctorEmail, DateOnly startDate, DateOnly endDate, CancellationToken ct)
    {
        
        var questionnaires = 
            await _questionnaireRepository.GetAssignedDoctorsQuestionnaires(doctorEmail, ct);
        
        var csv = new StringBuilder();
        csv.AppendLine("Id,Title,AssignmentDate,Guest,Status");
        
        long totalAmount = 0;
        foreach (var questionnaire in questionnaires)
        {
            var parser = new FhirJsonParser();
            var q = await parser.ParseAsync<Questionnaire>(questionnaire.QuestionnaireContent);
            var date = DateOnly.FromDateTime(DateTime.Parse(q.Date));
            if (!(date >= startDate && date <= endDate))
                continue;
            
            csv.AppendLine($"" +
                           $"{questionnaire.Id}," +
                           $"{q.Title}," +
                           $"{date}," +
                           $"{questionnaire.PatientQuestionnaires.First().PatientId}," +
                           $"{q.Status}");
            
            totalAmount++;
        }

        csv.AppendLine();
        csv.AppendLine($"Date range:,{startDate},{endDate}");
        csv.AppendLine($"Total Amount:,{totalAmount}");
        
        
        var fileName = $"QuestionnaireReport_{startDate:yyyyMMdd}_{endDate:yyyyMMdd}.csv";
        var fileBytes = Encoding.UTF8.GetBytes(csv.ToString());

        return (fileBytes, "text/csv", fileName);
    }

    public async Task<(byte[], string, string)> GetPatientReportAsync(string doctorEmail, string patientEmail, CancellationToken ct)
    {
        
        var questionnaires = 
            await _questionnaireRepository.GetQuestionnairesByDoctorAndPatientAsync(doctorEmail, patientEmail, ct);

        var patient = await _userRepository.GetUserAsync(patientEmail, ct);
        if(patient == null)
            throw new NullReferenceException($"Patient with email {patientEmail} was not found");
        
        var csv = new StringBuilder();
        csv.AppendLine($"Patient report on {patient.FirstName} {patient.LastName}");
        csv.AppendLine();
        csv.AppendLine("Id,Title,AssignmentDate,Guest,Status");
        
        long totalAmount = 0;
        foreach (var questionnaire in questionnaires)
        {
            var parser = new FhirJsonParser();
            var q = await parser.ParseAsync<Questionnaire>(questionnaire.QuestionnaireContent);
            var date = DateOnly.FromDateTime(DateTime.Parse(q.Date));
            
            csv.AppendLine($"" +
                           $"{questionnaire.Id}," +
                           $"{q.Title}," +
                           $"{date}," +
                           $"{patientEmail}," +
                           $"{q.Status}");
            
            totalAmount++;
        }

        csv.AppendLine();
        csv.AppendLine($"Total Amount:,{totalAmount}");
        
        
        var fileName = $"QuestionnaireReport_{doctorEmail}_{patientEmail}.csv";
        var fileBytes = Encoding.UTF8.GetBytes(csv.ToString());

        return (fileBytes, "text/csv", fileName);
    }
}