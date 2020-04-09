DECLARE @username VARCHAR(60)
SET @username = '$appName'

DECLARE @stmt VARCHAR(MAX)

SET @stmt = '
IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name =''' + @username +''')
BEGIN
    CREATE USER [' + @username + '] WITH DEFAULT_SCHEMA=[dbo], SID = $sid, TYPE = E;
END
ELSE
BEGIN
   DROP USER [' + @username + ']
   CREATE USER [' + @username + '] WITH DEFAULT_SCHEMA=[dbo], SID = $sid, TYPE = E;
END
IF IS_ROLEMEMBER(''db_owner'',''' + @username + ''') = 0
BEGIN
    ALTER ROLE db_owner ADD MEMBER ['+ @username +']
END'
EXEC(@stmt)