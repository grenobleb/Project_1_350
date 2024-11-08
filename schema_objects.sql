-- -- Tables -- --
CREATE TABLE drug_atc (
    id VARCHAR,
    atc_code VARCHAR
);

CREATE TABLE drug_names (
    id VARCHAR,
    name VARCHAR
);

CREATE TABLE meddra_all_indications (
    STITCH_compound_id VARCHAR,
    UMLS_concept_id_label VARCHAR,
    detection_method VARCHAR,
    concept_name VARCHAR,
    MedDRA_concept_type VARCHAR,
    UMLS_concept_id_MedDRA VARCHAR,
    MedDRA_concept_name VARCHAR
);

CREATE TABLE meddra_all_se (
    STITCH_compound_id_flat VARCHAR,
    STITCH_compound_id_stereo VARCHAR,
    UMLS_concept_id_label VARCHAR,
    MedDRA_concept_type VARCHAR,
    MedDRA_concept_id VARCHAR,
    MedDRA_concept_name VARCHAR
);

CREATE TABLE meddra_freq (
    STITCH_compound_id_flat VARCHAR,
    STITCH_compound_id_stereo VARCHAR,
    UMLS_concept_id_label VARCHAR,
    treatment_group VARCHAR,
    frequency VARCHAR,
    lower_frequency VARCHAR,
    upper_frequency VARCHAR,
    MedDRA_concept_type VARCHAR,
    MedDRA_concept_id VARCHAR,
    MedDRA_concept_name VARCHAR
);

CREATE TABLE meddra (
    UMLS_concept_id VARCHAR,
    MedDRA_id VARCHAR,
    kind_of_term VARCHAR,
    side_effect_name VARCHAR
);

CREATE TABLE drug_names_log (
    log_id SERIAL PRIMARY KEY,
    id VARCHAR,
    name VARCHAR,
    operation VARCHAR,
    operation_time TIMESTAMP
);

-- -- Functions -- --

-- -- Function 1 -- --
CREATE OR REPLACE FUNCTION GetDrugNamesInAlphabeticalOrder()
RETURNS TABLE (name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT name
    FROM drug_names
    ORDER BY name ASC;
END;
$$;

-- -- Function 2 -- --
CREATE OR REPLACE FUNCTION GetDrugsStartingWithA()
RETURNS TABLE (name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT name
    FROM drug_names
    WHERE name LIKE 'A%'
    ORDER BY name ASC;
END;
$$;

-- -- Function 3 -- --
CREATE OR REPLACE FUNCTION GetDrugsFromPToZ()
RETURNS TABLE (id VARCHAR, name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id, name
    FROM drug_names
    WHERE name >= 'P' AND name <= 'Z'
    ORDER BY name ASC;
END;
$$;

-- -- Function 4 -- --
CREATE OR REPLACE FUNCTION GetMedDRAIdAndSideEffectName()
RETURNS TABLE (MedDRA_id VARCHAR, side_effect_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT MedDRA_id, side_effect_name
    FROM meddra
    ORDER BY side_effect_name ASC;
END;
$$;

-- -- Function 5 -- --
CREATE OR REPLACE FUNCTION log_drug_names_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO drug_names_log (id, name, operation, operation_time)
        VALUES (NEW.id, NEW.name, 'INSERT', NOW());
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO drug_names_log (id, name, operation, operation_time)
        VALUES (NEW.id, NEW.name, 'UPDATE', NOW());
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO drug_names_log (id, name, operation, operation_time)
        VALUES (OLD.id, OLD.name, 'DELETE', NOW());
        RETURN OLD;
    END IF;
END;
$$;

-- -- Function 6 -- --
CREATE OR REPLACE FUNCTION GetSideEffectsForDrug(drug_name VARCHAR)
RETURNS TABLE (
    UMLS_concept_id VARCHAR,
    MedDRA_id VARCHAR,
    kind_of_term VARCHAR,
    side_effect_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.UMLS_concept_id,
        m.MedDRA_id,
        m.kind_of_term,
        m.side_effect_name
    FROM 
        meddra m
    JOIN 
        drug_names dn ON dn.id = m.UMLS_concept_id
    WHERE 
        dn.name = drug_name;
END;
$$;

-- -- Index -- --
CREATE INDEX idx_drug_name ON drug_names(name);
CREATE INDEX idx_drug_id ON drug_names(id);
CREATE INDEX idx_atc_id ON drug_atc(id);
CREATE INDEX idx_atc_code ON drug_atc(atc_code);
CREATE INDEX idx_meddra_id ON meddra(medDRA_id);
CREATE INDEX idx_meddra_UMLS ON meddra(UMLS_concept_id);
CREATE INDEX idx_meddra_term ON meddra(kind_of_term);
CREATE INDEX idx_meddra_side_effect_name ON meddra(side_effect_name);
CREATE INDEX idx_meddra_all_indications_STITCH_id ON meddra_all_indications(STITCH_compound_id)
CREATE INDEX idx_meddra_all_indications_UMLS_concept_id ON meddra_all_indications(UMLS_concept_id_MedDRA);CREATE INDEX idx_meddra_all_indication_detection_method ON meddra_all_indications(detection_method);
CREATE INDEX idx_meddra_all_inication_concept_name ON meddra_all_indications(concept_name);
CREATE INDEX idx_meddra_all_indication_MedDra_concept_type ON meddra_all_indications(MedDRA_concept_type);
CREATE INDEX idx_meddra_all_indication_UMLS_concept_id_MedDRA ON meddra_all_indications(UMLS_concept_id_MedDRA);
CREATE INDEX idx_meddra_all_indication_MedDRA_concept_name ON meddra_all_indications(MedDRA_concept_name);
CREATE INDEX idx_meddra_all_se_STITCH_compound_id_flat ON meddra_all_se(STITCH_compound_id_flat);
CREATE INDEX idx_meddra_all_se_STITCH_compound_id_stereo ON meddra_all_se(STITCH_compound_id_stereo);
CREATE INDEX idx_meddra_all_se_UMLS_concept_id_label ON meddra_all_se(UMLS_concept_id_label);
CREATE INDEX idx_meddra_all_se_MedDRA_concept_type ON meddra_all_se(MedDRA_concept_type);
CREATE INDEX idx_meddra_all_se_MedDRA_concept_id ON meddra_all_se(MedDRA_concept_id);
CREATE INDEX idx_meddra_all_se_MedDRA_concept_name ON meddra_all_se(MedDRA_concept_name);
CREATE INDEX idx_meddra_freq_STITCH_compound_id_flat ON meddra_freq(STITCH_compound_id_flat);
CREATE INDEX idx_meddra_freq_STITCH_compound_id_stereo ON meddra_freq(STITCH_compound_id_stereo);
CREATE INDEX idx_meddra_freq_UMLS_concept_id_label ON meddra_freq(UMLS_concept_id_label);
CREATE INDEX idx_meddra_freq_treatment_group ON meddra_freq(treatment_group);
CREATE INDEX idx_meddra_freq_frequency ON meddra_freq(frequency);
CREATE INDEX idx_meddra_freq_lower_frequency ON meddra_freq(lower_frequency);
CREATE INDEX idx_meddra_freq_upper_frequency ON meddra_freq(upper_frequency);
CREATE INDEX idx_meddra_freq_MedDRA_concept_type ON meddra_freq(MedDRA_concept_type);
CREATE INDEX idx_meddra_freq_MedDRA_concept_id ON meddra_freq(MedDRA_concept_id);
CREATE INDEX idx_meddra_freq_MedDRA_concept_name ON meddra_freq(MedDRA_concept_name);

-- -- Procedures -- --

-- -- Procedure 1 -- --
CREATE OR REPLACE PROCEDURE DisplaysSideEffectsForDrugName(IN drug_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM side_effect_name
    FROM meddra
    WHERE MedDRA_id = input_MedDRA_id;
END;
$$;

-- -- Procedure 2 -- --
CREATE OR REPLACE PROCEDURE DisplayDrugNameInAlphabeticalORder()
LANGUAGE plpgsql 
AS $$
BEGIN
    PERFORM * FROM G
    ORDER BY name ASC;
END;
$$

-- -- Procedure 3 -- --
CREATE OR REPLACE PROCEDURE InsertDrugNameAndLog(
    new_id VARCHAR,
    new_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert the new drug name into the drug_names table
    INSERT INTO drug_names (id, name)
    VALUES (new_id, new_name);

    -- Log the insertion operation in the drug_names_log table
    INSERT INTO drug_names_log (id, name, operation, operation_time)
    VALUES (new_id, new_name, 'INSERT', NOW());
END;
$$;
-- -- Procedure 4 -- --
CREATE OR REPLACE PROCEDURE InsertMeddraIndication(
    new_STITCH_compound_id VARCHAR,
    new_UMLS_concept_id_label VARCHAR,
    new_detection_method VARCHAR,
    new_concept_name VARCHAR,
    new_MedDRA_concept_type VARCHAR,
    new_UMLS_concept_id_MedDRA VARCHAR,
    new_MedDRA_concept_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert new indication into the meddra_all_indications table
    INSERT INTO meddra_all_indications (
        STITCH_compound_id,
        UMLS_concept_id_label,
        detection_method,
        concept_name,
        MedDRA_concept_type,
        UMLS_concept_id_MedDRA,
        MedDRA_concept_name
    )
    VALUES (
        new_STITCH_compound_id,
        new_UMLS_concept_id_label,
        new_detection_method,
        new_concept_name,
        new_MedDRA_concept_type,
        new_UMLS_concept_id_MedDRA,
        new_MedDRA_concept_name
    );
END;
$$;

-- -- Procedure 5 -- --
CREATE OR REPLACE PROCEDURE InsertMeddraSideEffect(
    new_STITCH_compound_id_flat VARCHAR,
    new_STITCH_compound_id_stereo VARCHAR,
    new_UMLS_concept_id_label VARCHAR,
    new_MedDRA_concept_type VARCHAR,
    new_MedDRA_concept_id VARCHAR,
    new_MedDRA_concept_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert the new side effect into the meddra_all_se table
    INSERT INTO meddra_all_se (
        STITCH_compound_id_flat,
        STITCH_compound_id_stereo,
        UMLS_concept_id_label,
        MedDRA_concept_type,
        MedDRA_concept_id,
        MedDRA_concept_name
    )
    VALUES (
        new_STITCH_compound_id_flat,
        new_STITCH_compound_id_stereo,
        new_UMLS_concept_id_label,
        new_MedDRA_concept_type,
        new_MedDRA_concept_id,
        new_MedDRA_concept_name
    );
END;
$$;

-- -- Triggers -- --
CREATE TRIGGER trigger_log_drug_names_changes
AFTER INSERT OR UPDATE OR DELETE
ON drug_names
FOR EACH ROW
EXECUTE FUNCTION log_drug_names_changes();

-- -- Constraints -- --
ALTER TABLE drug_names 
ADD CONSTRAINT drug_names_pkey 
PRIMARY KEY (id);

ALTER TABLE drug_atc
ADD CONSTRAINT fk_drug_atc_drug_names_id 
FOREIGN KEY (id) REFERENCES drug_names(id);

ALTER TABLE meddra_freq
ADD CONSTRAINT fk_meddra_freq_drug_names_id
FOREIGN KEY (STITCH_compound_id_flat) REFERENCES drug_names(id);

ALTER TABLE meddra_all_se
ADD CONSTRAINT fk_meddra_freq_drug_names_id
FOREIGN KEY (STITCH_compound_id_flat) REFERENCES drug_names(id);