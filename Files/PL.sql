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
    INSERT INTO PRESTAMO VALUES (a_idPre, a_fIni, a_fVen, 0, a_refAut, null, a_id_lector, a_numEj, a_idMat);
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

-- Procedimiento encargado de dar de alta a un nuevo lector.
CREATE OR REPLACE PROCEDURE p_lec_altaLec(vID_lector IN NUMBER, vNomL IN VARCHAR2, vApPL IN VARCHAR2, vApML IN VARCHAR2, vF_alta DATE, vTelef IN VARCHAR2,vCalle IN VARCHAR2, vColonia IN VARCHAR2, vNumero IN VARCHAR2,vID_tipo IN NUMBER)
AS
    vFecha_vig LECTOR.f_alta%TYPE;
BEGIN
    vfecha_vig := ADD_MONTHS(vf_alta, 12);

    INSERT INTO LECTOR VALUES(vid_lector,vNomL,vappl,vapml,vfecha_vig,vf_alta,vtelef,vcalle,vcolonia,vNumero,vid_tipo);
    DBMS_OUTPUT.PUT_LINE('Lector ' || vNomL || ' agregado.');
END;
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

    IF v_multa = null THEN
        v_multa := 0;
    END IF;

    RETURN (v_multa);
END;
/


----------------------------------------------------------------------------------------
-- DISPARADORES:

-- Disparador encargado de verificar que el usuario a realizar un prestamo
-- no cuente con alguna multa
CREATE OR REPLACE TRIGGER t_preYlec_bi BEFORE INSERT ON PRESTAMO FOR EACH ROW
DECLARE
    --Variables:
    v_multa     prestamo.multa%TYPE;
-- Procesos:
BEGIN
    v_multa := f_preYlec_mul(:new.id_lector);

    IF v_multa = 0 THEN
        --INSERT INTO PRESTAMO VALUES (:new.id_prestamo, :new.f_inicio, :new.f_venci, 0, :new.refre_aut, null, :new.id_lector, :new.numEj, :new.id_mat);
        :new.multa   := 0;
        :new.f_devol := null;
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
