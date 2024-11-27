db = db.getSiblingDB('api');
db.createCollection('test_db');

db.test_db.insertOne({ initialized: true });
