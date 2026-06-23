
CREATE TABLE Author
(
  ID        interger NOT NULL,
  Name      VARCHAR  NULL    ,
  Email     VARCHAR  NULL    ,
  Biography VARCHAR  NULL    ,
  ISBN      VARCHAR  NOT NULL,
  PRIMARY KEY (ID)
);

CREATE TABLE BOOK
(
  ISBN             VARCHAR NOT NULL,
  Title            VARCHAR NULL    ,
  Publication_Date date    NULL    ,
  Genre            VARCHAR NULL    ,
  PRIMARY KEY (ISBN)
);

CREATE TABLE Customer
(
  ID    Integer NULL    ,
  Name  VARCHAR NULL    ,
  Email VARCHAR NULL    ,
  ISBN  VARCHAR NOT NULL
);

ALTER TABLE Customer
  ADD CONSTRAINT FK_BOOK_TO_Customer
    FOREIGN KEY (ISBN)
    REFERENCES BOOK (ISBN);

ALTER TABLE Author
  ADD CONSTRAINT FK_BOOK_TO_Author
    FOREIGN KEY (ISBN)
    REFERENCES BOOK (ISBN);
