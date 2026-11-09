SELECT e.employee_id,
       e.last_name,
       d.department_name
FROM hr.employees e
JOIN hr.departments d
  ON d.department_id = e.department_id
WHERE d.department_id = 60
ORDER BY e.employee_id;

SELECT XMLSERIALIZE(
         DOCUMENT
           XMLELEMENT("empleados",
             XMLAGG(
               XMLELEMENT("empleado",
                 XMLATTRIBUTES(e.employee_id AS "id"),
                 XMLFOREST(
                   e.last_name AS "apellido",
                   d.department_name AS "departamento"
                 )
               ) ORDER BY e.employee_id
             )
           )
         AS VARCHAR2(4000) INDENT SIZE = 2
       ) AS resultado_xml
FROM hr.employees e
JOIN hr.departments d
  ON d.department_id = e.department_id
WHERE d.department_id = 60;

BEGIN
  DBMS_XMLSCHEMA.registerSchema(
    schemaURL => 'empleados_lab1.xsd',
    schemaDoc => q'~
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:element name="empleados">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="empleado" maxOccurs="unbounded">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="apellido" type="xs:string"/>
                    <xs:element name="departamento" type="xs:string"/>
                  </xs:sequence>
                  <xs:attribute name="id" type="xs:integer" use="required"/>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:schema>
    ~',
    local     => TRUE,
    genTypes  => FALSE,
    genTables => FALSE
  );
END;
/

CREATE TABLE empleados_xml_lab (
  documento XMLTYPE NOT NULL,
  CONSTRAINT empleados_xml_valido
    CHECK (XMLISVALID(documento, 'empleados_lab1.xsd') = 1)
);

INSERT INTO empleados_xml_lab (documento)
VALUES (
  XMLTYPE(
    '<empleados>
       <empleado id="104">
         <apellido>Miller</apellido>
         <departamento>IT</departamento>
       </empleado>
     </empleados>'
  )
);

INSERT INTO empleados_xml_lab (documento)
VALUES (
  XMLTYPE(
    '<empleados>
       <empleado id="ABC">
         <apellido>Miller</apellido>
         <departamento>IT</departamento>
       </empleado>
     </empleados>'
  )
);