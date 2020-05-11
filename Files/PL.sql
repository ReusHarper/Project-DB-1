-- Descripcion de tablas:
DESCRIBE AUTOR;
DESCRIBE CUENTA;
DESCRIBE MATERIAL;
DESCRIBE LIBRO;
DESCRIBE TESIS;
DESCRIBE DIRECTOR;
DESCRIBE EJEMPLAR;
DESCRIBE PRESTAMO;
DESCRIBE LECTOR;
DESCRIBE TIPO_LECTOR;

-- Instrucciones pl/sql

----------------------------------------------------------------------------------------
-- PROCEDIMIENTOS:

-- Procedimiento encargado de ingresar una insercion en la tabla de prestamos
CREATE OR REPLACE PROCEDURE p_preYlec_ins(a_idPre IN NUMBER, a_fIni IN DATE, a_fVen IN DATE, a_refAut IN NUMBER, a_id_lector IN NUMBER, a_numEj IN NUMBER, a_idMat IN NUMBER)
AS
    -- Variables
-- Procesos
BEGIN
    INSERT INTO PRESTAMO (id_prestamo, f_inicio, f_venci, multa, refre_aut, id_lector, numEj, id_mat)
    VALUES (a_idPre, a_fIni, a_fVen, 0, a_refAut, a_id_lector, a_numEj, a_idMat);
END p_preYlec_ins;
/

-- Procedimiento encargado de actualizar el estatus de un ejemplar al efectuarse
-- un prestamo
CREATE OR REPLACE PROCEDURE p_pre_upd(a_numEj IN NUMBER)
AS
    -- Variables
-- Procesos
BEGIN
    UPDATE EJEMPLAR
    SET    estatus   = 'EN PRESTAMO'
    WHERE  a_numEj   = numEj;
END p_pre_upd;
/


----------------------------------------------------------------------------------------
-- FUNCIONES:

-- Funcion encargada de retornar el total de multas de algun usuario especificado
CREATE OR REPLACE FUNCTION f_preYlec_mul(a_idLec IN NUMBER)
RETURN NUMBER
    -- Variables:
    IS
        v_multa prestamo.multa%TYPE;
-- Procesos:
BEGIN
    SELECT COUNT(p.multa)
    INTO   v_multa
    FROM   prestamo p, lector l
    WHERE  p.id_lector = l.id_lector
    AND    l.id_lector = a_idLec;

    RETURN (v_multa);
END;
/


----------------------------------------------------------------------------------------
-- DISPARADORES:

-- Disparador encargado de verificar que el usuario a realizar un prestamo
-- no cuente con alguna multa
CREATE OR REPLACE TRIGGER t_preYlec_bi BEFORE INSERT ON PRESTAMO FOR EACH ROW
DECLARE
    --Variables
    v_multa     prestamo.multa%TYPE;
-- Procesos
BEGIN
    v_multa := f_preYlec_mul(:new.id_lector);

    IF v_multa = 0 THEN
        p_preYlec_ins(:new.id_prestamo, :new.f_inicio, :new.f_venci, :new.refre_aut, :new.id_lector, :new.numEj, :new.id_mat);
    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR: El id del usuario cuenta con una multa. No es posible ejercer la operacion.');
    END IF;
END;
/

-- Disparador encargado de actualizar el estatus de un ejemplar al efectuarse
-- un prestamo
CREATE OR REPLACE TRIGGER t_pre_eje_ai AFTER INSERT ON PRESTAMO FOR EACH ROW
DECLARE
    --Variables
-- Procesos
BEGIN
    p_pre_upd(:new.numEj);
END;
/


-- Eliminacion de instrucciones pl/sql

DROP PROCEDURE p_preYlec_ins;
DROP PROCEDURE p_pre_upd;

DROP FUNCTION  f_preYlec_mul;

DROP TRIGGER   t_preYlec_bi;
DROP TRIGGER   t_pre_eje_ai;








/**/
