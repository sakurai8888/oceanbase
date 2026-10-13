-- Oracle Tenant TDE --- 

-- Reference Dod: https://en.oceanbase.com/docs/common-oceanbase-database-10000000001717360


show parameters like 'tde_method';

-- None : Disabled which is for unencrypted deployments
-- Internal : Keystore are stored inside Oceanbase sys tables
-- BKMI : External KMS Server 


-- Enable TDE At Tenant --
Alter system set tde_method = 'Internal'



-- Create Key store and protect with password

ADMINISTER KEY MANAGEMENT CREATE KEYSTORE keystore_name IDENTIFIED BY "P@ssw0rdP@ssw0rd";



-- Enable the keystore 
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "P@ssw0rdP@ssw0rd";




-- Generate a master key , the password must be the same as the keystore 
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "P@ssw0rdP@ssw0rd";





-- Check if there are any encrypted tablespace.
SELECT table_name,encryptionalg,encrypted  FROM sys.V$OB_ENCRYPTED_TABLES;


SELECT * FROM sys.V$OB_ENCRYPTED_TABLES;

-- Create an encrypted tablespace 
CREATE TABLESPACE sectest_ts1 ENCRYPTION USING 'aes-256';


-- Create a table under the tablespace 
CREATE TABLE t1 (id1 int, id2 int) TABLESPACE sectest_ts1;





-- Atler a big table into the encrypted tablespace 
ALTER TABLE ora_user01.big_tab  TABLESPACE sectest_ts1;
