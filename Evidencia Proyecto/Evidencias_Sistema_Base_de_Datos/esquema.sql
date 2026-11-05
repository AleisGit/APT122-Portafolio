--
-- PostgreSQL database dump
--

\restrict BmfVvSNuInQUZuDTmdf4EXcMTBD2au7aiALovZKXcaF4CqeaiW0KuU3TvBXvgOd

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: empresa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.empresa (
    id integer NOT NULL,
    codigo character varying(12) GENERATED ALWAYS AS (('EMP-'::text || lpad((id)::text, 4, '0'::text))) STORED NOT NULL,
    rut character varying(12) NOT NULL,
    nombre character varying(80) NOT NULL,
    rubro character varying(40) NOT NULL,
    region character varying(40) NOT NULL,
    trabajadores integer NOT NULL,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    actualizado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_empresa_nombre_minimo CHECK ((length(TRIM(BOTH FROM nombre)) >= 3)),
    CONSTRAINT ck_empresa_trabajadores_positivos CHECK ((trabajadores > 0))
);


--
-- Name: empresa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.empresa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: empresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.empresa_id_seq OWNED BY public.empresa.id;


--
-- Name: enlace_clave; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enlace_clave (
    id integer NOT NULL,
    miembro_id integer NOT NULL,
    proposito character varying(12) NOT NULL,
    huella character varying(64) NOT NULL,
    expira_en timestamp with time zone NOT NULL,
    usado_en timestamp with time zone,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_enlace_clave_proposito_valido CHECK (((proposito)::text = ANY ((ARRAY['invitacion'::character varying, 'recuperacion'::character varying])::text[])))
);


--
-- Name: enlace_clave_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enlace_clave_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enlace_clave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enlace_clave_id_seq OWNED BY public.enlace_clave.id;


--
-- Name: miembro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.miembro (
    id integer NOT NULL,
    nombre character varying(80) NOT NULL,
    correo character varying(254) NOT NULL,
    rol character varying(20) NOT NULL,
    empresa_id integer,
    clave_hash character varying(255),
    activo boolean DEFAULT true NOT NULL,
    version_sesion integer DEFAULT 0 NOT NULL,
    intentos_fallidos integer DEFAULT 0 NOT NULL,
    bloqueado_hasta timestamp with time zone,
    ultimo_acceso timestamp with time zone,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    actualizado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_miembro_empresa_segun_rol CHECK ((((rol)::text = 'soporte'::text) = (empresa_id IS NULL))),
    CONSTRAINT ck_miembro_rol_valido CHECK (((rol)::text = ANY ((ARRAY['soporte'::character varying, 'admin_empresa'::character varying, 'asistente_empresa'::character varying])::text[])))
);


--
-- Name: miembro_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.miembro_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: miembro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.miembro_id_seq OWNED BY public.miembro.id;


--
-- Name: periodo_poliza; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.periodo_poliza (
    id integer NOT NULL,
    poliza_id integer NOT NULL,
    anio smallint NOT NULL,
    trimestre smallint NOT NULL,
    prima_devengada bigint NOT NULL,
    siniestros_incurridos bigint NOT NULL,
    siniestralidad numeric(9,4) GENERATED ALWAYS AS (round(((siniestros_incurridos)::numeric / (prima_devengada)::numeric), 4)) STORED NOT NULL,
    CONSTRAINT ck_periodo_poliza_prima_positiva CHECK ((prima_devengada > 0)),
    CONSTRAINT ck_periodo_poliza_siniestros_no_negativos CHECK ((siniestros_incurridos >= 0)),
    CONSTRAINT ck_periodo_poliza_trimestre_valido CHECK (((trimestre >= 1) AND (trimestre <= 4)))
);


--
-- Name: periodo_poliza_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.periodo_poliza_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periodo_poliza_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.periodo_poliza_id_seq OWNED BY public.periodo_poliza.id;


--
-- Name: poliza; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poliza (
    id integer NOT NULL,
    numero character varying(12) GENERATED ALWAYS AS (('POL-'::text || ((1000 + id))::text)) STORED NOT NULL,
    empresa_id integer NOT NULL,
    ramo character varying(20) NOT NULL,
    aseguradora character varying(60) NOT NULL,
    asegurados integer NOT NULL,
    comision_pct numeric(4,1) NOT NULL,
    inicio_vigencia date NOT NULL,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    actualizado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_poliza_asegurados_positivos CHECK ((asegurados > 0)),
    CONSTRAINT ck_poliza_comision_en_rango CHECK (((comision_pct > (0)::numeric) AND (comision_pct <= (30)::numeric))),
    CONSTRAINT ck_poliza_ramo_valido CHECK (((ramo)::text = ANY ((ARRAY['Salud'::character varying, 'Dental'::character varying, 'Vida'::character varying, 'Catastrófico'::character varying])::text[])))
);


--
-- Name: poliza_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.poliza_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poliza_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.poliza_id_seq OWNED BY public.poliza.id;


--
-- Name: empresa id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresa ALTER COLUMN id SET DEFAULT nextval('public.empresa_id_seq'::regclass);


--
-- Name: enlace_clave id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enlace_clave ALTER COLUMN id SET DEFAULT nextval('public.enlace_clave_id_seq'::regclass);


--
-- Name: miembro id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.miembro ALTER COLUMN id SET DEFAULT nextval('public.miembro_id_seq'::regclass);


--
-- Name: periodo_poliza id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodo_poliza ALTER COLUMN id SET DEFAULT nextval('public.periodo_poliza_id_seq'::regclass);


--
-- Name: poliza id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poliza ALTER COLUMN id SET DEFAULT nextval('public.poliza_id_seq'::regclass);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: empresa pk_empresa; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresa
    ADD CONSTRAINT pk_empresa PRIMARY KEY (id);


--
-- Name: enlace_clave pk_enlace_clave; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enlace_clave
    ADD CONSTRAINT pk_enlace_clave PRIMARY KEY (id);


--
-- Name: miembro pk_miembro; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.miembro
    ADD CONSTRAINT pk_miembro PRIMARY KEY (id);


--
-- Name: periodo_poliza pk_periodo_poliza; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodo_poliza
    ADD CONSTRAINT pk_periodo_poliza PRIMARY KEY (id);


--
-- Name: poliza pk_poliza; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poliza
    ADD CONSTRAINT pk_poliza PRIMARY KEY (id);


--
-- Name: empresa uq_empresa_codigo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresa
    ADD CONSTRAINT uq_empresa_codigo UNIQUE (codigo);


--
-- Name: empresa uq_empresa_rut; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresa
    ADD CONSTRAINT uq_empresa_rut UNIQUE (rut);


--
-- Name: enlace_clave uq_enlace_clave_huella; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enlace_clave
    ADD CONSTRAINT uq_enlace_clave_huella UNIQUE (huella);


--
-- Name: periodo_poliza uq_periodo_poliza_trimestre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodo_poliza
    ADD CONSTRAINT uq_periodo_poliza_trimestre UNIQUE (poliza_id, anio, trimestre);


--
-- Name: poliza uq_poliza_numero; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poliza
    ADD CONSTRAINT uq_poliza_numero UNIQUE (numero);


--
-- Name: ix_enlace_clave_miembro_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_enlace_clave_miembro_id ON public.enlace_clave USING btree (miembro_id);


--
-- Name: ix_miembro_empresa_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_miembro_empresa_id ON public.miembro USING btree (empresa_id);


--
-- Name: ix_poliza_empresa_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_poliza_empresa_id ON public.poliza USING btree (empresa_id);


--
-- Name: uq_empresa_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_empresa_nombre ON public.empresa USING btree (lower(TRIM(BOTH FROM nombre)));


--
-- Name: uq_miembro_correo; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_miembro_correo ON public.miembro USING btree (lower((correo)::text));


--
-- Name: enlace_clave fk_enlace_clave_miembro_id_miembro; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enlace_clave
    ADD CONSTRAINT fk_enlace_clave_miembro_id_miembro FOREIGN KEY (miembro_id) REFERENCES public.miembro(id) ON DELETE CASCADE;


--
-- Name: miembro fk_miembro_empresa_id_empresa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.miembro
    ADD CONSTRAINT fk_miembro_empresa_id_empresa FOREIGN KEY (empresa_id) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- Name: periodo_poliza fk_periodo_poliza_poliza_id_poliza; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodo_poliza
    ADD CONSTRAINT fk_periodo_poliza_poliza_id_poliza FOREIGN KEY (poliza_id) REFERENCES public.poliza(id) ON DELETE CASCADE;


--
-- Name: poliza fk_poliza_empresa_id_empresa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poliza
    ADD CONSTRAINT fk_poliza_empresa_id_empresa FOREIGN KEY (empresa_id) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict BmfVvSNuInQUZuDTmdf4EXcMTBD2au7aiALovZKXcaF4CqeaiW0KuU3TvBXvgOd

