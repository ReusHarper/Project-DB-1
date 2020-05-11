-- Secuencias:
CREATE SEQUENCE seq_aut_idAutor
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     9999999999
    CACHE        20
    NOCYCLE;

CREATE SEQUENCE seq_mat_idMat
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     9999999999
    CACHE        20
    NOCYCLE;

CREATE SEQUENCE seq_lib_numAd
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     9999999999
    CACHE        20
    NOCYCLE;

CREATE SEQUENCE seq_tes_idTes
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     9999999999
    CACHE        20
    NOCYCLE;

CREATE SEQUENCE seq_eje_numEj
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     9999999999
    CACHE        20
    NOCYCLE;

CREATE SEQUENCE seq_pre_idPre
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     9999999999
    CACHE        20
    CYCLE;

CREATE SEQUENCE seq_lec_idLec
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     9999999999
    CACHE        20
    NOCYCLE;

CREATE SEQUENCE seq_tipLec_idTip
    START WITH   1
    INCREMENT BY 1
    MINVALUE     1
    MAXVALUE     3
    CACHE        5
    NOCYCLE;

SELECT seq_aut_idAutor.CURRVAL   FROM dual;
SELECT seq_mat_idMat.CURRVAL     FROM dual;
SELECT seq_lib_numAd.CURRVAL     FROM dual;
SELECT seq_tes_idTes.CURRVAL     FROM dual;
SELECT seq_eje_numEj.CURRVAL     FROM dual;
SELECT seq_pre_idPre.CURRVAL     FROM dual;
SELECT seq_lec_idLec.CURRVAL     FROM dual;
SELECT seq_tipLec_idTip.CURRVAL  FROM dual;

DROP SEQUENCE seq_aut_idAutor;
DROP SEQUENCE seq_mat_idMat;
DROP SEQUENCE seq_lib_numAd;
DROP SEQUENCE seq_tes_idTes;
DROP SEQUENCE seq_eje_numEj;
DROP SEQUENCE seq_pre_idPre;
DROP SEQUENCE seq_lec_idLec;
DROP SEQUENCE seq_tipLec_idTip;