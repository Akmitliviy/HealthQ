CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250105204130_Initial') THEN
    CREATE TYPE public.gender AS ENUM ('female', 'male', 'special');
    CREATE TYPE public.user_type AS ENUM ('administrator', 'doctor', 'patient');
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250105204130_Initial') THEN
    CREATE TABLE public.users (
        email character varying(254) NOT NULL,
        username character varying(64) NOT NULL,
        password_salt character varying(64) NOT NULL,
        password_hash character varying(128) NOT NULL,
        first_name character varying(50) NOT NULL,
        last_name character varying(50) NOT NULL,
        birth_date date NOT NULL,
        gender gender NOT NULL,
        phone_number character varying(13) NOT NULL,
        user_type user_type NOT NULL,
        CONSTRAINT "PK_users" PRIMARY KEY (email)
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250105204130_Initial') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250105204130_Initial', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250126170230_Questionnaire') THEN
    CREATE TABLE public.questionnaires (
        id uuid NOT NULL,
        questionnaire_content text NOT NULL,
        CONSTRAINT "PK_questionnaires" PRIMARY KEY (id)
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250126170230_Questionnaire') THEN
    CREATE TABLE public.user_questionnaire (
        "UserId" character varying(250) NOT NULL,
        "QuestionnaireId" uuid NOT NULL,
        CONSTRAINT "PK_user_questionnaire" PRIMARY KEY ("UserId", "QuestionnaireId"),
        CONSTRAINT "FK_user_questionnaire_questionnaires_QuestionnaireId" FOREIGN KEY ("QuestionnaireId") REFERENCES public.questionnaires (id) ON DELETE CASCADE,
        CONSTRAINT "FK_user_questionnaire_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users (email) ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250126170230_Questionnaire') THEN
    CREATE INDEX "IX_user_questionnaire_QuestionnaireId" ON public.user_questionnaire ("QuestionnaireId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250126170230_Questionnaire') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250126170230_Questionnaire', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128140717_DoctorPatient_Table') THEN
    CREATE TABLE public.doctor_patient (
        "DoctorEmail" character varying(254) NOT NULL,
        "PatientEmail" character varying(254) NOT NULL,
        CONSTRAINT "PK_doctor_patient" PRIMARY KEY ("DoctorEmail", "PatientEmail"),
        CONSTRAINT "FK_doctor_patient_users_DoctorEmail" FOREIGN KEY ("DoctorEmail") REFERENCES public.users (email) ON DELETE CASCADE,
        CONSTRAINT "FK_doctor_patient_users_PatientEmail" FOREIGN KEY ("PatientEmail") REFERENCES public.users (email) ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128140717_DoctorPatient_Table') THEN
    CREATE INDEX "IX_doctor_patient_PatientEmail" ON public.doctor_patient ("PatientEmail");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128140717_DoctorPatient_Table') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250128140717_DoctorPatient_Table', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient DROP CONSTRAINT "FK_doctor_patient_users_DoctorEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient DROP CONSTRAINT "FK_doctor_patient_users_PatientEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    DROP TABLE public.user_questionnaire;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.questionnaires ADD owner_email character varying(254) NOT NULL DEFAULT '';
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient ADD "DoctorUserEmail" character varying(254);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient ADD "PatientUserEmail" character varying(254);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE TABLE public.doctors (
        user_email character varying(254) NOT NULL,
        CONSTRAINT "PK_doctors" PRIMARY KEY (user_email),
        CONSTRAINT "FK_doctors_users_user_email" FOREIGN KEY (user_email) REFERENCES public.users (email)
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE TABLE public.patients (
        user_email character varying(254) NOT NULL,
        CONSTRAINT "PK_patients" PRIMARY KEY (user_email),
        CONSTRAINT "FK_patients_users_user_email" FOREIGN KEY (user_email) REFERENCES public.users (email)
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE TABLE public.patient_questionnaire (
        "PatientEmail" character varying(254) NOT NULL,
        "QuestionnaireId" uuid NOT NULL,
        "UserEmail" character varying(254) NOT NULL,
        "QuestionnaireId1" uuid NOT NULL,
        CONSTRAINT "PK_patient_questionnaire" PRIMARY KEY ("PatientEmail", "QuestionnaireId"),
        CONSTRAINT "FK_patient_questionnaire_patients_PatientEmail" FOREIGN KEY ("PatientEmail") REFERENCES public.patients (user_email) ON DELETE CASCADE,
        CONSTRAINT "FK_patient_questionnaire_questionnaires_QuestionnaireId" FOREIGN KEY ("QuestionnaireId") REFERENCES public.questionnaires (id) ON DELETE CASCADE,
        CONSTRAINT "FK_patient_questionnaire_questionnaires_QuestionnaireId1" FOREIGN KEY ("QuestionnaireId1") REFERENCES public.questionnaires (id) ON DELETE CASCADE,
        CONSTRAINT "FK_patient_questionnaire_users_UserEmail" FOREIGN KEY ("UserEmail") REFERENCES public.users (email) ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE INDEX "IX_questionnaires_owner_email" ON public.questionnaires (owner_email);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE INDEX "IX_doctor_patient_DoctorUserEmail" ON public.doctor_patient ("DoctorUserEmail");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE INDEX "IX_doctor_patient_PatientUserEmail" ON public.doctor_patient ("PatientUserEmail");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE INDEX "IX_patient_questionnaire_QuestionnaireId" ON public.patient_questionnaire ("QuestionnaireId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE INDEX "IX_patient_questionnaire_QuestionnaireId1" ON public.patient_questionnaire ("QuestionnaireId1");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    CREATE INDEX "IX_patient_questionnaire_UserEmail" ON public.patient_questionnaire ("UserEmail");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient ADD CONSTRAINT "FK_doctor_patient_doctors_DoctorEmail" FOREIGN KEY ("DoctorEmail") REFERENCES public.doctors (user_email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient ADD CONSTRAINT "FK_doctor_patient_doctors_DoctorUserEmail" FOREIGN KEY ("DoctorUserEmail") REFERENCES public.doctors (user_email);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient ADD CONSTRAINT "FK_doctor_patient_patients_PatientEmail" FOREIGN KEY ("PatientEmail") REFERENCES public.patients (user_email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.doctor_patient ADD CONSTRAINT "FK_doctor_patient_patients_PatientUserEmail" FOREIGN KEY ("PatientUserEmail") REFERENCES public.patients (user_email);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    ALTER TABLE public.questionnaires ADD CONSTRAINT "FK_questionnaires_doctors_owner_email" FOREIGN KEY (owner_email) REFERENCES public.doctors (user_email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250128191945_DoctorTbl_PatientTbl') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250128191945_DoctorTbl_PatientTbl', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient DROP CONSTRAINT "FK_doctor_patient_doctors_DoctorEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient DROP CONSTRAINT "FK_doctor_patient_doctors_DoctorUserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient DROP CONSTRAINT "FK_doctor_patient_patients_PatientEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient DROP CONSTRAINT "FK_doctor_patient_patients_PatientUserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.patient_questionnaire DROP CONSTRAINT "FK_patient_questionnaire_patients_PatientEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.patient_questionnaire DROP CONSTRAINT "FK_patient_questionnaire_questionnaires_QuestionnaireId1";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.patient_questionnaire DROP CONSTRAINT "FK_patient_questionnaire_users_UserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    DROP INDEX public."IX_patient_questionnaire_QuestionnaireId1";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    DROP INDEX public."IX_patient_questionnaire_UserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    DROP INDEX public."IX_doctor_patient_DoctorUserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    DROP INDEX public."IX_doctor_patient_PatientUserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.patient_questionnaire DROP COLUMN "QuestionnaireId1";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.patient_questionnaire DROP COLUMN "UserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient DROP COLUMN "DoctorUserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient DROP COLUMN "PatientUserEmail";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.patient_questionnaire RENAME COLUMN "PatientEmail" TO "PatientId";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient RENAME COLUMN "PatientEmail" TO "PatientId";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient RENAME COLUMN "DoctorEmail" TO "DoctorId";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER INDEX public."IX_doctor_patient_PatientEmail" RENAME TO "IX_doctor_patient_PatientId";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient ADD CONSTRAINT "FK_doctor_patient_doctors_DoctorId" FOREIGN KEY ("DoctorId") REFERENCES public.doctors (user_email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.doctor_patient ADD CONSTRAINT "FK_doctor_patient_patients_PatientId" FOREIGN KEY ("PatientId") REFERENCES public.patients (user_email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    ALTER TABLE public.patient_questionnaire ADD CONSTRAINT "FK_patient_questionnaire_patients_PatientId" FOREIGN KEY ("PatientId") REFERENCES public.patients (user_email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250129113455_ManyToMany') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250129113455_ManyToMany', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250202234756_DeleteBehaviour') THEN
    ALTER TABLE public.doctors DROP CONSTRAINT "FK_doctors_users_user_email";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250202234756_DeleteBehaviour') THEN
    ALTER TABLE public.patients DROP CONSTRAINT "FK_patients_users_user_email";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250202234756_DeleteBehaviour') THEN
    ALTER TABLE public.doctors ADD CONSTRAINT "FK_doctors_users_user_email" FOREIGN KEY (user_email) REFERENCES public.users (email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250202234756_DeleteBehaviour') THEN
    ALTER TABLE public.patients ADD CONSTRAINT "FK_patients_users_user_email" FOREIGN KEY (user_email) REFERENCES public.users (email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250202234756_DeleteBehaviour') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250202234756_DeleteBehaviour', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226083326_AddClinicalImpression') THEN
    CREATE TABLE public.clinical_impressions (
        id uuid NOT NULL,
        questionnaire_id uuid NOT NULL,
        questionnaire_content text NOT NULL,
        CONSTRAINT "PK_clinical_impressions" PRIMARY KEY (id),
        CONSTRAINT "FK_clinical_impressions_questionnaires_questionnaire_id" FOREIGN KEY (questionnaire_id) REFERENCES public.questionnaires (id) ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226083326_AddClinicalImpression') THEN
    CREATE TABLE public."Files" (
        id integer GENERATED BY DEFAULT AS IDENTITY,
        file_name text NOT NULL,
        file_data bytea NOT NULL,
        content_type text NOT NULL,
        CONSTRAINT "PK_Files" PRIMARY KEY (id)
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226083326_AddClinicalImpression') THEN
    CREATE INDEX "IX_clinical_impressions_questionnaire_id" ON public.clinical_impressions (questionnaire_id);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226083326_AddClinicalImpression') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250226083326_AddClinicalImpression', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226183621_AddObservationModel') THEN
    CREATE TABLE public.observations (
        id uuid NOT NULL,
        clinical_impression_id uuid NOT NULL,
        observation_content text NOT NULL,
        CONSTRAINT "PK_observations" PRIMARY KEY (id),
        CONSTRAINT "FK_observations_clinical_impressions_clinical_impression_id" FOREIGN KEY (clinical_impression_id) REFERENCES public.clinical_impressions (id) ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226183621_AddObservationModel') THEN
    CREATE INDEX "IX_observations_clinical_impression_id" ON public.observations (clinical_impression_id);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226183621_AddObservationModel') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250226183621_AddObservationModel', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226214304_FixClinicalImpression') THEN
    ALTER TABLE public.clinical_impressions ADD patient_id character varying(254) NOT NULL DEFAULT '';
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226214304_FixClinicalImpression') THEN
    CREATE INDEX "IX_clinical_impressions_patient_id" ON public.clinical_impressions (patient_id);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226214304_FixClinicalImpression') THEN
    ALTER TABLE public.clinical_impressions ADD CONSTRAINT "FK_clinical_impressions_patients_patient_id" FOREIGN KEY (patient_id) REFERENCES public.patients (user_email) ON DELETE CASCADE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226214304_FixClinicalImpression') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250226214304_FixClinicalImpression', '9.0.0');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250227162238_TemplateModel') THEN
    CREATE TABLE public.templates (
        id uuid NOT NULL,
        questionnaire_content text NOT NULL,
        owner_email character varying(254) NOT NULL,
        CONSTRAINT "PK_templates" PRIMARY KEY (id)
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250227162238_TemplateModel') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20250227162238_TemplateModel', '9.0.0');
    END IF;
END $EF$;
COMMIT;

