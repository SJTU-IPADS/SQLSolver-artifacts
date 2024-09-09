create table Bookstore (
    id varchar(20),
    name varchar(50),
    city varchar(15),
    address varchar(50),
    primary key (id)
);
create table Author (
    author_id varchar(20),
    name varchar(50),
    city varchar(15),
    address varchar(50),
    age int,
    primary key (author_id)
);
create table Book (
    book_id varchar(20),
    title varchar(50),
    author varchar(20),
    price int,
    store varchar(20),
    primary key (book_id),
    foreign key (author) references Author (author_id),
    foreign key (store) references Bookstore (id)
);
create table person (
    license_number varchar(50),
    name varchar(50),
    address varchar(50),
    primary key (license_number)
);
--
create table car (
     car_regnum varchar(50),
     model varchar(50),
     year varchar(50),
     primary key (car_regnum)
);
--
create table accident (
    report_number varchar(50),
    date varchar(50),
    location varchar(50),
    primary key (report_number)
);
--
create table owns (
    license_number varchar(50),
    car_regnum varchar(50),
    primary key (license_number, car_regnum)
);
--
create table participated (
    license_number varchar(50),
    car_regnum varchar(50),
    report_number varchar(50),
    damage_amount int,
    primary key (license_number, car_regnum, report_number)
);
create table student (
    student_id varchar(20),
    name varchar(50),
    primary key (student_id)
);
create table books (
    isbn varchar(20),
    title varchar(50),
    author varchar(20),
    publisher varchar(20),
    primary key (isbn)
);
create table loan (
    student_id varchar(20),
    isbn varchar(20),
    issue_date varchar(20),
    due_date varchar(20),
    primary key (student_id, isbn)
);
create table employee (
    employee_name varchar(50),
    street varchar(50),
    city varchar(50),
    primary key (employee_name)
);
--
create table department (
    department_name varchar(50),
    city varchar(50),
    primary key (department_name)
);
--
create table works (
    employee_name varchar(50),
    department_name varchar(50),
    job_title varchar(50),
    salary int,
    primary key (employee_name)
);
--
create table manages (
    employee_name varchar(50),
    manager_name varchar(50),
    primary key (employee_name)
);