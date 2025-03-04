-- NIVEL 1
-- EJERCICIO 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

-- CREAMOS LA TABLA CREDIT CARD

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(50) PRIMARY KEY,
    iban VARCHAR(50) ,
    pan VARCHAR(30) ,
    pin VARCHAR(10) ,
    cvv VARCHAR(4),
    expiring_date VARCHAR(20)
);
-- CARGAMOS LOS DATOS DESDE datos_introducir_credit

-- EJECUTAMOS ESTE CODIGO PARA ESTABLECER LA RELACION CON LA TABLA TRANSACTION

ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card 
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id)
ON DELETE SET NULL;
--     

-- EJERCICIO 2-- 
-- El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: 
-- R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

-- Verifiquem el canvi
SELECT 
    *
FROM
    credit_card
WHERE
    id = 'CcU-2938';

-- EJERCICIO 3 
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
-- Id
-- 108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id
-- CcU-9999
-- company_id
-- b-9999
-- user_id
-- 9999
-- lat
-- 829.999
-- longitude
-- -117.999
-- amount
-- 111.11
-- declined
-- 0


-- (PRIMERO INSERTAMOS LOS SIGUIENTES DATOS PARA QUE LA QUERY FUNCIONE--transaction
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) 
VALUES ('CcU-9999', '5424465566813633', '1234567789','3257','984', '2025-10-30');
INSERT INTO company (id, company_name) 
VALUES ('b-9999', 'Empresa Nueva');

-- AHORA SI PODEMOS INGRESAR LOS NUEVOS DATOS A LA TABLA TRANSACTION

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 829.999, -117.999, 111.11, 0);

-- CORROBORAMOS QUE LOS DATOS SEAN CORRECTOS
SELECT * FROM transaction 
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';


-- EJERCICIO 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
-- ELIMINAMOS LA COLUMNA pan

ALTER TABLE credit_card DROP COLUMN pan;

-- CORROBORAMOS QUE HAYA SIDO CORRECTAMENTE ELIMINADA

SELECT pan from credit_card;

DESCRIBE credit_card;

-- NIVEL 2 
-- EJERCICIO 1 
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
-- ELIMINAMOS EL REGISTRO CON id "02C6201E-D90A-1859-B4EE-88D2986D3B02"

DELETE FROM transaction 
WHERE id ="02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- CORROBORAMOS QUE EL REGISTRO YA NO EXISTA
SELECT * from transaction 
WHERE id="02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- EJERCICIO 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
--  Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
--  Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

-- CREAMOS LA VISTAMARKETING

CREATE VIEW VistaMarketing AS 
SELECT 
c.company_name AS NameCompanya,
c.phone AS Telefono,
c.country AS PaisResidencia,
round(avg(t.amount),2) AS MitjaCompraRealizat
FROM company c 
JOIN transaction t 
ON t.company_id=c.id
WHERE DECLINED = 0
GROUP BY c.id, c.company_name,c.phone, c.country;

-- ORDENAMOS:
SELECT * FROM Vistamarketing
ORDER BY MitjaCompraRealizat DESC;

-- EJERCICIO 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
-- FILTRAMOS POR PAIS 'GERMANY.
SELECT NameCompanya 
FROM vistamarketing
WHERE PaisResidencia = "Germany";

-- NIVEL 3 
-- EJERCICIO 1

-- CARGAMOS LA TABLA USER ORIGINAL CON EL SIGUIENTE COMANDO
-- CREATE INDEX idx_user_id ON transaction(user_id);
--  
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );
    
    -- CARGAMOS LOS DATOS DESDE datos_introducir_user 
    
    -- PARA MODIFICAR LA RELACION ENTRE USER Y TRANSACTION (de fuerte a débil) debemos ejecutar los siguientes comandos:

-- ELIMINAR LA FK DE LA TABLA USER 

ALTER TABLE user
DROP FOREIGN KEY user_ibfk_1;

-- CAMBIAMOS EL NOMBRE DE LA TABLA USER POR DATA_USER
ALTER TABLE user RENAME data_user;

    
ALTER TABLE transaction 
ADD CONSTRAINT fk_user_transaction 
FOREIGN KEY (user_id) 
REFERENCES data_user(id) 
ON DELETE SET NULL;
    
    -- esto da un error porque tenemos un registro dentro de transaction que no existe dentro de la tabla user asi que debemos agregarlo y luego volver a ejecutarlo
    
 SELECT user_id FROM transaction WHERE user_id NOT IN (SELECT id FROM data_user);  -- ASI VEMOS SI NOS FALTA UN REGISTRO DENTRO DE LA TABLA Y LO AGREGAMOS:
 
INSERT INTO data_user (id, name, surname, phone, email, 
birth_date, country, city, postal_code, address) 
VALUES (9999, 'Rocio', 'Rivero', '603515267','email@ejemplo.com', 
'2000-01-01', 'Spain', 'Barcelona', '08004', 'xxxxxx');


-- AGREGAMOS LA COLUMNA fecha_actual con formato DATE

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

-- ELIMINAMOS LA COLUMNA WEBSITE DE LA TABLA COMPANY
ALTER TABLE company
DROP COLUMN website;

-- CAMBIAMOS EL NOMBRE DE LA COLUMNA EMAIL POR PERSONAL MAIL EN DATA_USER
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;


-- EJERCICIO 2
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- ID de la transacció
-- Nom de l'usuari/ària
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

-- CREAMOS LA VISTA INFORMETECNICO

CREATE VIEW InformeTecnico AS
SELECT 
t.id AS IdTransaccion,
du.name AS NombreUser,
du.surname AS ApellidoUser,
cc.iban AS IbanTarjeta,
c.company_name AS NombreCompanya
FROM transaction t
JOIN data_user du ON du.id=t.user_id
JOIN credit_card cc ON cc.id=t.credit_card_id
JOIN company c ON t.company_id=c.id;

SELECT * 
FROM informetecnico 
ORDER BY IdTransaccion DESC;



