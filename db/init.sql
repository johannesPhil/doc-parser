-- Create dev database
CREATE DATABASE legal_docs_db
  WITH OWNER = johannes
  ENCODING = 'UTF8'
  CONNECTION LIMIT = -1;

-- Create test database
CREATE DATABASE legal_docs_test
  WITH OWNER = johannes
  ENCODING = 'UTF8'
  CONNECTION LIMIT = -1;
