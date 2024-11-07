-- Tables
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

-- Functions
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

--Index
CREATE INDEX idx_drug_name ON drug_names(drug_name);

-- Procedures
CREATE OR REPLACE PROCEDURE 

-- Constraints
ALTER TABLE drug_names 
ADD CONSTRAINT drug_names_pkey 
PRIMARY KEY (id);

ALTER TABLE drug_atc
ADD CONSTRAINT fk_drug_atc_drug_names_id 
FOREIGN KEY (id) REFERENCES drug_names(id);

ALTER TABLE meddra 
ADD CONSTRAINT fk_meddra_drug_names_id 
FOREIGN KEY (umls_concept_id) REFERENCES drug_names(id);