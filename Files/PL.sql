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

-- Procedimiento encargado de actualizar el numero de refrendos por cada resello que el lector ejerza:
CREATE OR REPLACE PROCEDURE p_pre_ref_upd(a_idPre IN NUMBER)
AS
    -- Variables:
-- Procesos:
BEGIN
    UPDATE PRESTAMO
    SET    refre_aut   = refre_aut - 1
    WHERE  id_prestamo = a_idPre;
END p_pre_ref_upd;
/

-- Procedimiento encargado de insertar un prestamo:
CREATE OR REPLACE PROCEDURE p_InsertaPrestamo (vF_inic DATE,/* vF_fin DATE*/ vMulta NUMBER/*,vRefre NUMBER*/,vF_devol DATE,vID_lec NUMBER,vNumEj NUMBER,vID_Mat NUMBER )
AS
    -- Variables:
    vTipoLector LECTOR.id_tipo%TYPE;
    vDiasPres TIPO_LECTOR.lim_dia%TYPE;
    vRefre NUMBER;
    vF_fin DATE;
-- Procesos:
BEGIN
    SELECT L.id_tipo,tl.lim_dia,tl.lim_refrendo INTO vTipoLector,vDiasPres,vRefre FROM LECTOR L JOIN TIPO_LECTOR TL ON L.id_tipo=TL.id_tipo
    WHERE L.ID_LECTOR=vID_lec;

    vF_fin:=vF_inic+(vDiasPres);

    INSERT INTO PRESTAMO VALUES(vF_inic,vF_fin,vMulta,vRefre,vF_devol,vID_lec,vNumEj,vID_Mat);
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

    IF v_multa IS null THEN
        v_multa := 0;
    END IF;

    RETURN (v_multa);
END;
/

-- Funcion encargada de retornar los refrendos actuales y autorizados por el lector en cada prestamo
CREATE OR REPLACE FUNCTION f_preYlec_ref(a_idLec IN NUMBER)
RETURN NUMBER
    -- Variables:
    IS
        v_refAut prestamo.refre_aut%TYPE;
-- Procesos:
BEGIN
    SELECT p.refre_aut
    INTO   v_refAut
    FROM   prestamo p, lector l
    WHERE  p.id_lector = l.id_lector
    AND    l.id_lector = a_idLec;

    RETURN (v_refAut);
END;
/

-- Funcion encargada de retornar la fecha de devolucion
CREATE OR REPLACE FUNCTION f_preYlec_fDev(a_idLec IN NUMBER)
RETURN DATE
    -- Variables:
    IS
        v_fDev prestamo.f_devol%TYPE;
-- Procesos:
BEGIN
    SELECT p.f_devol
    INTO   v_fDev
    FROM   prestamo p, lector l
    WHERE  p.id_lector = l.id_lector
    AND    p.id_lector = a_idLec;

    --IF v_fDev IS null THEN
    --    v_fDev := SYSDATE;
    --END IF;

    RETURN (v_fDev);
END;
/

-- Funcion encargada de retornar la fecha de vencimiento
CREATE OR REPLACE FUNCTION f_preYlec_fVen(a_idLec IN NUMBER)
RETURN DATE
    -- Variables:
    IS
        v_fVen prestamo.f_venci%TYPE;
-- Procesos:
BEGIN
    SELECT p.f_venci
    INTO   v_fVen
    FROM   prestamo p, lector l
    WHERE  p.id_lector = l.id_lector
    AND    p.id_lector = a_idLec;

    RETURN (v_fVen);
END;
/

-- Funcion encargada de retornar la nueva fecha de devolucion dependiendo del tipo lector:
CREATE OR REPLACE FUNCTION f_pre_fDev_upd(a_idPre IN NUMBER)
RETURN DATE
    -- Variables:
    IS
        v_tipoLec tipo_lector.tipoLector%TYPE;
        v_fDev    prestamo.f_devol%TYPE;
-- Procesos:
BEGIN
    SELECT  t.tipoLector
    INTO    v_tipoLec
    FROM    tipo_lector t
    JOIN    lector l
    ON      t.id_tipo = l.id_tipo
    JOIN    prestamo p
    ON      l.id_lector   = p.id_lector
    WHERE   p.id_prestamo = a_idPre;

    IF v_tipoLec = 'E' THEN
        v_fDev := SYSDATE + 8;
    ELSIF v_tipoLec = 'P' THEN
        v_fDev := SYSDATE + 15;
    ELSE
        v_fDev := SYSDATE + 30;
    END IF;

    RETURN (v_fDev);
END f_pre_fDev_upd;
/

-- Funcion encargada de obtener la multa total generado por cada lector
CREATE OR REPLACE FUNCTION f_CalculaMulta
(vID_lec IN prestamo.id_lector%TYPE, vNumEj IN prestamo.numEj%TYPE, vID_Mat IN prestamo.id_mat%TYPE)--TENEMOS QUE TOMAR TODA LA PK COMPLETA DE PRESTAMO
RETURN NUMBER --VA A SER EL TOTAL A DEBER
    IS
        vMulta          NUMBER(6);
        vFechaInic      DATE;
        vFechaFin       DATE;
        vDias           NUMBER(3);
        vFechaDevo      DATE;
        vFechaActual    DATE;
BEGIN
    vFechaActual:=SYSDATE;
    --Tomamos las fechas iniciales y finales del prestamo en cuestion
    SELECT f_inicio,f_venci,f_devol INTO vFechaInic, vFechaFin,vFechaDevo FROM PRESTAMO
    WHERE (id_lector=vID_lec) AND (numEj=vnumej) AND (id_mat=vid_mat);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN


    IF (vfechainic IS NULL) THEN--primero corroboramos que exista algún préstamo de ese lector
        vMulta:=0;
    ELSIF (vfechainic IS NOT NULL) THEN--SI YA HAY ALGUN PRESTAMO
        IF (vFechaDevo)<(vFechaFIn) THEN--SI YA SE ENTREGO A TIEMPO
            vMulta:=0;
        ELSIF (vFechaDevo)>(vFechaFIn) THEN--SI SE ENTREGO A DESTIEMPO
            vDias:=vfechadevo-vfechafin;
            vMulta:=10*vDias;
        ELSIF (vfechaDevo IS NULL) AND (vFechaActual<vFechaFin) THEN --SI AUN NO LO ENTREGO Y EESTOY A TIEMPO
            vMulta:=0;
        ELSIF (vfechaDevo IS NULL) AND (vFechaActual>vFechaFin) THEN --SI AUN NO LO ENTREGO Y NO EESTOY A TIEMPO1
            vDias:=vFechaActual-vFechaFin;
            vMulta:=10*vDias;
        END IF;
    END IF;

RETURN (vMulta);
END ftCalculaMulta;
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

-- Trigger para verificar si el usuario tiene multa:
CREATE OR REPLACE TRIGGER tiVerificarMulta BEFORE INSERT ON PRESTAMO FOR EACH ROW
DECLARE
    --Variables
    v_multa prestamo.multa%TYPE;--dinero que puede deber el usuario
-- Procesos
BEGIN
    v_multa := ftCalculaMulta(:new.id_lector,:new.numEj,:new.id_mat);

    IF v_multa = 0 THEN
        spInsertaPrestamo(:new.f_inicio, v_multa , :new.f_devol ,:new.id_lector, :new.numEj, :new.id_mat);
    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR: El id del usuario cuenta con una multa de: '||v_multa);
    END IF;
END;
/

-- Disparador encargado de actualizar el estatus de un ejemplar al efectuarse
-- un prestamo
CREATE OR REPLACE TRIGGER t_pre_eje_ai AFTER INSERT ON PRESTAMO FOR EACH ROW
DECLARE
    --Variables
    PRAGMA AUTONOMOUS_TRANSACTION;
-- Procesos
BEGIN
    p_pre_upd(:new.numEj);
END;
/

-- Disparador encargado de realzar un resello del prestamo del material prestado al lector
CREATE OR REPLACE TRIGGER t_pre_ref_bi BEFORE UPDATE OF f_devol ON PRESTAMO FOR EACH ROW
DECLARE
    --Variables:
    v_fDev      prestamo.f_devol%TYPE;
    v_fVen      prestamo.f_venci%TYPE;
    v_refAut    prestamo.refre_aut%TYPE;
-- Procesos:
BEGIN
    v_fDev   := f_preYlec_fDev(:old.id_prestamo);
    v_fVen   := f_preYlec_fVen(:old.id_prestamo);
    v_refAut := f_preYlec_ref(:old.id_lector);

    IF v_fDev = v_fVen THEN
        IF v_refAut > 0 THEN
            --v_refAut := :old.refre_aut - 1;
            --v_fVen   := f_pre_fDev_upd(:old.id_prestamo);
            DBMS_OUTPUT.PUT_LINE(v_refAut);
            DBMS_OUTPUT.PUT_LINE(v_fVen);
            --:new.refre_aut := :old.refre_aut - 1;
            --:new.f_devol   := f_pre_fDev_upd(:old.id_prestamo);
            --p_pre_ref_upd(:old.id_prestamo);
            --p_pre_fDev_upd(:old.id_prestamo);
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: No es posible ejercer el resello. El numero de refrendos ha llegado al limite.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR: No es posible ejercer el resello. La fecha de vencimiento no coincide con la fecha de devolucion.');
    END IF;
END;
/

-- Disparador encargado de ingresar a un lector de baja:
CREATE OR REPLACE TRIGGER t_DetallesLectorBaja
AFTER DELETE
ON LECTOR
FOR EACH ROW
BEGIN
    INSERT INTO LECTOR_BAJA(
    id_lector        ,
    nomL             ,
    apPL             ,
    apML             ,
    telef            ,
    calle            ,
    colonia          ,
    numero           ,
    fech_baja)
    VALUES (
        :OLD.id_lector  ,
        :OLD.nomL       ,
        :OLD.apPL       ,
        :OLD.apML       ,
        :OLD.telef      ,
        :OLD.calle      ,
        :OLD.colonia    ,
        :OLD.numero     ,
        SYSDATE);
END;
/


-- Eliminacion de instrucciones pl/sql

DROP PROCEDURE p_preYlec_ins;
DROP PROCEDURE p_pre_upd;

DROP FUNCTION  f_preYlec_mul;

DROP TRIGGER   t_preYlec_bi;
DROP TRIGGER   t_pre_eje_ai;








/**/
