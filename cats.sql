CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER NOT NULL,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER NOT NULL,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO houses (address) VALUES ("1850 Dwight Way");
INSERT INTO humans (fname, lname, house_id) VALUES ("Sean", "Omlor", 1);
INSERT INTO humans (fname, lname, house_id) VALUES ("Alli", "Crawford", 1);
INSERT INTO cats (name, owner_id) VALUES ("Sebastian", 1);
INSERT INTO cats (name, owner_id) VALUES ("Aleister", 1);
INSERT INTO cats (name, owner_id) VALUES ("Esther", 2);
INSERT INTO cats (name, owner_id) VALUES ("Boosie", 2);
