SELECT XMLELEMENT(NAME item) AS e0,
       XMLELEMENT(NAME item, XMLATTRIBUTES(c_int AS id, c_grp)) AS e1,
       XMLELEMENT(NAME item, c_text, '-', c_grp) AS e2,
       XMLELEMENT(NAME item, XMLATTRIBUTES(c_int AS id), XMLELEMENT(NAME txt, c_text)) AS e3,
       XMLFOREST(c_int AS id, c_text, c_grp AS grp) AS f,
       XMLCONCAT(XMLELEMENT(NAME a, c_int), XMLELEMENT(NAME b, c_grp)) AS cc,
       XMLPI(NAME php) AS pi0,
       XMLPI(NAME php, 'echo ' || c_int) AS pi1,
       XMLCOMMENT('row ' || c_int) AS cm
FROM lmc_small
WHERE c_int < 4
ORDER BY c_int;

SELECT XMLPARSE(DOCUMENT '<r><v>' || c_int || '</v></r>') AS d1,
       XMLPARSE(CONTENT '<v>' || c_int || '</v>  ' PRESERVE WHITESPACE) AS d2,
       XMLPARSE(CONTENT ' <v>x</v> ' STRIP WHITESPACE) AS d3,
       XMLSERIALIZE(DOCUMENT XMLPARSE(DOCUMENT '<r/>') AS text) AS s1,
       XMLSERIALIZE(CONTENT XMLELEMENT(NAME v, c_text) AS varchar(100)) AS s2,
       XMLROOT(XMLPARSE(DOCUMENT '<r/>'), VERSION '1.0', STANDALONE YES) AS r1,
       XMLROOT(XMLPARSE(DOCUMENT '<r/>'), VERSION NO VALUE, STANDALONE NO) AS r2,
       XMLROOT(XMLPARSE(DOCUMENT '<r/>'), VERSION '1.1', STANDALONE NO VALUE) AS r3,
       XMLROOT(XMLPARSE(DOCUMENT '<r/>'), VERSION '1.0') AS r4
FROM lmc_small
WHERE c_int < 3
ORDER BY c_int;

SELECT c_int,
       XMLEXISTS('/r/v[text()="1"]' PASSING BY REF XMLPARSE(DOCUMENT '<r><v>1</v></r>')) AS ex0,
       XMLEXISTS('//v' PASSING XMLPARSE(DOCUMENT '<r><v>' || c_int || '</v></r>')) AS ex1,
       XMLEXISTS('//v' PASSING XMLPARSE(DOCUMENT '<r><v/></r>') BY VALUE) AS ex2,
       XMLEXISTS('//v' PASSING BY VALUE XMLPARSE(DOCUMENT '<r><v/></r>') BY REF) AS ex3,
       XMLPARSE(DOCUMENT '<r/>') IS DOCUMENT AS isdoc,
       XMLPARSE(CONTENT 'a<b/>') IS NOT DOCUMENT AS notdoc
FROM lmc_small
WHERE c_int < 3
ORDER BY c_int;

SELECT count(*)
FROM lmc_small
WHERE true BETWEEN XMLPARSE(DOCUMENT '<a/>') IS DOCUMENT AND true
  AND false BETWEEN XMLPARSE(DOCUMENT '<a/>') IS NOT DOCUMENT AND true;

SELECT x.*
FROM XMLTABLE('/rows/row' PASSING XMLPARSE(DOCUMENT '<rows><row id="1"><n>a</n></row><row id="2"><n>b</n></row></rows>')
              COLUMNS id int PATH '@id',
                      n text PATH 'n' DEFAULT 'none' NOT NULL,
                      ord FOR ORDINALITY) AS x
ORDER BY x.id;

SELECT s.c_int, x.v
FROM lmc_small s,
     LATERAL XMLTABLE('/r/v' PASSING XMLELEMENT(NAME r, XMLELEMENT(NAME v, s.c_int), XMLELEMENT(NAME v, s.c_grp))
                      COLUMNS v int PATH '.') x
WHERE s.c_int < 4
ORDER BY 1, 2;

SELECT x.*
FROM XMLTABLE(XMLNAMESPACES('http://example.com/ns' AS e, 'http://example.com/x' AS x),
              '/e:rows/e:row' PASSING XMLPARSE(DOCUMENT '<rows xmlns="http://example.com/ns"><row><v>7</v></row></rows>')
              COLUMNS v int PATH 'e:v') x;
