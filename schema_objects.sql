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
    kind_of_term VARCHAR,
    MedDRA_id VARCHAR,
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

CREATE OR REPLACE FUNCTION GetDrugsFromPtoZ()
RETURNS TABLE (name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT name
    FROM drug_names
    WHERE name LIKE '[P-Z]%'
    ORDER BY name ASC;
END;

CREATE OR REPLACE FUNCTION GetMeDRAIDAndSideEEffectName()
RETURNS TABLE (MedDRA_id VARCHAR, side_effect_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT MedDRA_id, side_effect_name
    FROM meddra
    ORDER BY MedDRA_id ASC;
END;

/*
CREATE OR REPLACE FUNCTION GetDrugSideEffectsForDrugNameFreqAboveNum(drug_name VARCHAR, num INT)
RETURNS TABLE (side_effect_name VARCHAR, frequency VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT side_effect_name, frequency
    FROM meddra_freq mf JOIN drug_names dn 
    ON mf.STITCH_compound_id_flat = dn.id
    WHERE dn.name = drug_name AND mf.frequency > num;
END;
$$;
*/

--Index
CREATE INDEX idx_drug_name ON drug_names(name);
CREATE INDEX idx_drug_id ON drug_names(id);
CREATE INDEX idx_atc_id ON drug_atc(id);
CREATE INDEX idx_atc_code ON drug_atc(atc_code);
CREATE INDEX idx_meddra_id ON meddra(medDRA_id);
CREATE INDEX idx_meddra_UMLS ON meddra(UMLS_concept_id);
CREATE INDEX idx_meddra_term ON meddra(kind_of_term);
CREATE INDEX idx_meddra_side_effect_name ON meddra(side_effect_name);
CREATE INDEX idx_meddra_all_indications_STITCH_id ON meddra_all_indications(STITCH_compound_id)
CREATE INDEX idx_meddra_all_indications_UMLS_concept_id ON meddra_all_indications(UMLS_concept_id_label);
CREATE INDEX idx_meddra_all_indication_detection_method ON meddra_all_indications(detection_method);
CREATE INDEX idx_meddra_all_inication_concept_name ON meddra_all_indications(concept_name);
CREATE INDEXX idx_meddra_all_indi

-- Procedures
CREATE OR REPLACE PROCEDURE DisplaysSideEffectsForDrugName(IN drug_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM side_effect_name
    FROM meddra
    WHERE MedDRA_id = input_MedDRA_id;
END;
$$;

CREATE OR REPLACE PROCEDURE DisplayDrugNameInAlphabeticalORder()
LANGUAGE plpgsql 
AS $$
BEGIN
    PERFORM * FROM G
    ORDER BY name ASC;
END;

-- Constraints
ALTER TABLE drug_names 
ADD CONSTRAINT drug_names_pkey 
PRIMARY KEY (id);

ALTER TABLE drug_atc
ADD CONSTRAINT fk_drug_atc_drug_names_id 
FOREIGN KEY (id) REFERENCES drug_names(id);

/* 
ALTER TABLE meddra_all_indications
ADD CONSTRAINT fk_meddra_all_indications_drug_names_id 
FOREIGN KEY (STITCH_compound_id) REFERENCES drug_names(id);

Key (stitch_compound_id)=(CID100000242) is not present in table "drug_names
*/

ALTER TABLE meddra_all_se
ADD CONSTRAINT fk_meddra_all_se_drug_names_id
FOREIGN KEY (STITCH_compound_id_flat) REFERENCES drug_names(id);

ALTER TABLE meddra_freq
ADD CONSTRAINT fk_meddra_freq_drug_names_id
FOREIGN KEY (STITCH_compound_id_flat) REFERENCES drug_names(id);
