require 'test_helper'

class C32Test < MiniTest::Unit::TestCase
  
  def setup
    collection_fixtures('records', '_id')
    @pi = HealthDataStandards::Import::C32::PatientImporter.instance
    @record = Record.find('4dcbecdb431a5f5878000004')
    c32 = HealthDataStandards::Export::C32.export(@record)
    doc = Nokogiri::XML(c32)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    @patient = @pi.parse_c32(doc)
  end
  
  def test_demographics
    doc = Nokogiri::XML(HealthDataStandards::Export::C32.export(@record))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    parsed = Record.new
    @pi.get_demographics(parsed, doc)

    assert_equal 'Rosa', parsed.first
    assert_equal 'Vasquez', parsed.last
    assert_equal 'F', parsed.gender
    assert_equal 345426614, parsed.birthdate
  end
  
  def test_encounters
    encounter = @patient.encounters[0]
    assert_equal 1267322332, encounter.time
    assert_equal({"CPT" => ["99201"]}, encounter.codes)
  end
  
  def test_allergies
    allergy = @patient.allergies[0]
    assert_equal 1271810257, allergy.as_point_in_time
    assert_equal({"RxNorm" => ["70618"]}, allergy.codes)
  end
  
  def test_conditions
    condition = @patient.conditions[0]
    assert_equal 1269776601, condition.as_point_in_time
    assert_equal({"SNOMED-CT" => ["160603005"]}, condition.codes)
  end
  
  def test_vitals
    vital = @patient.vital_signs[0]
    assert_equal 1266664414, vital.time
    assert_equal({"SNOMED-CT" => ["225171007"]}, vital.codes)
    assert_equal "26", vital.value[:scalar]
  end
  
  def test_procedures
    procedure = @patient.procedures[0]
    assert_equal 1273150428, procedure.time
    assert_equal({"SNOMED-CT" => ["171055003"]}, procedure.codes)
  end

  def test_results
    result = @patient.results[0]
    assert_equal 1257901150, result.time
    assert_equal({"SNOMED-CT" => ["439958008"]}, result.codes)
  end

  def test_immunizations
    immunization = @patient.immunizations[0]
    assert_equal 1264529050, immunization.time
    assert_equal({"RxNorm" => ["854931"]}, immunization.codes)
  end

  def test_medications
    medication = @patient.medications[0]
    assert_equal 1271810257, medication.start_time
    assert_equal({"RxNorm" => ["105075"]}, medication.codes)
  end

  def test_care_goals
    care_goal = @patient.care_goals[0]
    assert_equal 1278043200, care_goal.time
    assert_equal({"CPT" => ["97804"]}, care_goal.codes)
  end

  def test_social_history
    social_history = @patient.social_history[0]
    assert_equal 1265778000, social_history.time
    assert_equal({"ICD-9-CM" => ["250"]}, social_history.codes)
  end
  
  def test_medical_equipment
    medical_equipment = @patient.medical_equipment[0]
    assert_equal 1279252800, medical_equipment.time
    assert_equal({"SNOMED-CT" => ["56961003"]}, medical_equipment.codes)
  end
end
