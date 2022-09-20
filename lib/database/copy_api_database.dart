/**
 * Manages the tables and inserts needed to start the database
 */
void copyAPIDatabase(db, version) async {
  // Create tables
  await db.execute(_users);
  await db.execute(_visits);
  await db.execute(_user_visits);
  await db.execute(_owners);
  await db.execute(_property_types);
  await db.execute(_properties);
  await db.execute(_requests);
  await db.execute(_agricultural_machines);
  await db.execute(_property_agricultural_machines);
  await db.execute(_property_visits);
  await db.execute(_vehicles);
  await db.execute(_property_vehicles);
  await db.execute(_userIdTrigger);
  await db.execute(_visitIdTrigger);
  await db.execute(_userVisitIdTrigger);
  await db.execute(_ownerIdTrigger);
  await db.execute(_propertyTypeIdTrigger);
  await db.execute(_propertyIdTrigger);
  await db.execute(_requestIdTrigger);
  await db.execute(_agriculturalMachineIdTrigger);
  await db.execute(_propertyAgriculturalMachineIdTrigger);
  await db.execute(_propertyVisitIdTrigger);
  await db.execute(_vehicleIdTrigger);
  await db.execute(_propertyVehicleIdTrigger);
}

/**
 * Create Users Table
 */
String get _users => '''
  CREATE TABLE users (
    _id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    createdAt DATETIME,
    updatedAt DATETIME
  );
''';

/**
 * Create Visits Table
 */
String get _visits => '''
  CREATE TABLE visits (
    _id VARCHAR(255) PRIMARY KEY,
    car VARCHAR(255) NOT NULL,
    latitude VARCHAR(255) NOT NULL,
    longitude VARCHAR(255) NOT NULL,
    visit_date DATETIME NOT NULL,
    createdAt DATETIME,
    updatedAt DATETIME
  );
''';

/**
 * Create Visits Table
 */
String get _user_visits => '''
  CREATE TABLE user_visits (
    _id VARCHAR(255) PRIMARY KEY,
    fk_user_id VARCHAR(255),
    fk_visit_id VARCHAR,
    createdAt DATETIME,
    updatedAt DATETIME,
    FOREIGN KEY (fk_user_id) REFERENCES Users (_id),
    FOREIGN KEY (fk_visit_id) REFERENCES Visits (_id)
  );
''';

/** 
 * Create Owners Table
 */
String get _owners => '''
  CREATE TABLE owners (
    _id VARCHAR(255) PRIMARY KEY,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    createdAt DATETIME,
    updatedAt DATETIME
  );
''';

/**
 * Create Property Types Table
 */
String get _property_types => '''
  CREATE TABLE property_types (
    _id VARCHAR(255) PRIMARY KEY,
    name VARCHAR (255) NOT NULL,
    createdAt DATETIME,
    updatedAt DATETIME
  );
''';

/**
 * Create Properties Table
 */
String get _properties => '''
  CREATE TABLE properties(
    _id VARCHAR(255) PRIMARY KEY,
    code VARCHAR(255),
    has_geo_board BOOLEAN,
    qty_people INT,
    has_cams BOOLEAN,
    has_phone_signal BOOLEAN,
    has_internet BOOLEAN,
    has_gun BOOLEAN,
    has_gun_local BOOLEAN,
    gun_local_description TEXT,
    qty_agricultural_defensives INT,
    oservations TEXT,
    fk_owner_id VARCHAR(255),
    fk_property_type_id VARCHAR(255),
    createdAt DATETIME,
    updatedAt DATETIME,
    FOREIGN KEY (fk_owner_id) REFERENCES Owners (_id),
    FOREIGN KEY (fk_property_type_id) REFERENCES Property_types (_id)
  );
''';

/**
 * Create Requests Table
 */
String get _requests => '''
  CREATE TABLE requests (
    _id VARCHAR(255) PRIMARY KEY,
    agency VARCHAR(255) NOT NULL,
    has_success BOOL NOT NULL DEFAULT FALSE,
    fk_property_id VARCHAR(255),
    createdAt DATETIME,
    updatedAt DATETIME,
    FOREIGN KEY (fk_property_id) REFERENCES Properties (_id)
  );
''';

/**
 * Create Agricultural Machines Table
 */
String get _agricultural_machines => '''
  CREATE TABLE agricultural_machines (
    _id VARCHAR (255) PRIMARY KEY,
    name VARCHAR(255),
    brand VARCHAR(255),
    createdAt DATETIME,
    updatedAt DATETIME
  );
''';

/**
 * Create Property Agricultural Machines Table
 */
String get _property_agricultural_machines => '''
  CREATE TABLE property_agricultural_machines (
    _id VARCHAR(255) PRIMARY KEY,
    other_machine VARCHAR(255),
    other_machine_brand VARCHAR (255),
    fk_property_id VARCHAR(255),
    fk_agricultural_machine_id VARCHAR(255),
    createdAt DATETIME,
    updatedAt DATETIME,
    FOREIGN KEY (fk_property_id) REFERENCES Properties (_id),
    FOREIGN KEY (fk_agricultural_machine_id) REFERENCES Agricultural_machines (_id)
  );
''';

/**
 * Create Property Visits Table
 */
String get _property_visits => '''
  CREATE TABLE property_visits (
    _id VARCHAR(255) PRIMARY KEY,
    fk_property_id VARCHAR(255),
    fk_visit_id VARCHAR(255),
    createdAt DATETIME,
    updatedAt DATETIME,
    FOREIGN KEY (fk_property_id) REFERENCES Properties (_id),
    FOREIGN KEY (fk_visit_id) REFERENCES Visits (_id)
  );
''';

/**
 * Create Vehicles Table
 */
String get _vehicles => '''
  CREATE TABLE vehicles (
    _id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    createdAt DATETIME,
    updatedAt DATETIME
  );
''';

/**
 * Create Property Vehicles Table
 */
String get _property_vehicles => '''
  CREATE TABLE property_vehicles (
    _id VARCHAR(255) PRIMARY KEY,
    other_vehicles VARCHAR(255),
    other_vehicle_brand VARCHAR(255),
    color VARCHAR(255) NOT NULL,
    fk_vehicle_id VARCHAR(255),
    fk_property_id VARCHAR(255),
    createdAt DATETIME,
    updatedAt DATETIME,
    FOREIGN KEY (fk_vehicle_id) REFERENCES Vehicles (_id),
    FOREIGN KEY (fk_property_id) REFERENCES Properties (_id)
  );
''';

/**
 * Set a trigger to always generate a uuid
 */
String get _userIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_1
  AFTER INSERT ON users
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE users SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _visitIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_2
  AFTER INSERT ON visits
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE visits SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _userVisitIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_3
  AFTER INSERT ON user_visits
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE user_visits SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _ownerIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_4
  AFTER INSERT ON owners
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE owners SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _propertyTypeIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_5
  AFTER INSERT ON property_types
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE property_types SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _propertyIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_6
  AFTER INSERT ON properties
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE properties SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _requestIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_7
  AFTER INSERT ON requests
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE requests SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _agriculturalMachineIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_8
  AFTER INSERT ON agricultural_machines
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE agricultural_machines SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _propertyAgriculturalMachineIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_9
  AFTER INSERT ON property_agricultural_machines
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE property_agricultural_machines SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _propertyVisitIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_10
  AFTER INSERT ON property_visits
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE property_visits SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _vehicleIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_11
  AFTER INSERT ON vehicles
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE vehicles SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';

String get _propertyVehicleIdTrigger => '''
  CREATE TRIGGER AutoGenerateGUID_RELATION_12
  AFTER INSERT ON property_vehicles
  FOR EACH ROW
  WHEN (New._id IS NULL)
  BEGIN
    UPDATE property_vehicles SET _id = (select lower(hex(randomblob(12)))) WHERE rowid = NEW.rowid;
  END;
''';
