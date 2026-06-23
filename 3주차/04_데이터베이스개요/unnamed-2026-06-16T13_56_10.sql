
CREATE TABLE student_course_1nf
(
  student_id       INTEGER NULL    ,
  course_id        TEXT    NULL    ,
  student_name     TEXT    NULL    ,
  course_name      TEXT    NULL    ,
  grade            TEXT    NULL    ,
  professor_name   TEXT    NULL    ,
  professor_office TEXT    NULL    ,
  dept_code        TEXT    NULL    ,
  dept_name        TEXT    NULL    ,
  dept_building    TEXT    NULL    ,
  PRIMARY KEY (student_id, course_id)
);
