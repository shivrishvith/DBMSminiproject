create database health;
use health;

drop table if exists patient;
drop table if exists doctor;
drop table if exists nurse;
drop table if exists record;
drop table if exists branch;

create table patient(
	customerID int not null auto_increment,
    customerName varchar(20),
    customerContact varchar(10),
    customerAddress varchar(30),
    password varchar(50),
    employeeID int,
    unique(customerName,password),
    primary key(customerID),
    foreign key (employeeID) references employee(employeeID) on delete cascade
);

create table branch(
	branchID int NOT NULL auto_increment,
	branchName varchar(20),
    branchCity varchar(20),
    password varchar(50),
    primary key (branchID),
    unique (branchName,password)
);


create table record(
	accountID int not null auto_increment,
    balance float(10,2)default 0,
    customerID int,
    primary key (accountID),
    foreign key (customerID) references customer(customerID) on delete cascade
);

create table loan(
	loanID int not null auto_increment,
    amount float(10,2),
    sanctionDate datetime,
    amountSanctioned float(10,2),
    accountID int,
    primary key (loanID),
    foreign key (accountID) references accountDetails(accountID) on delete cascade
);

create table payment(
	paymentID int not null auto_increment,
    paymentDate datetime,
	paymentAmount float(10,2),
    remarks varchar(50),
    loanID int,
    primary key (paymentID,loanID),
    foreign key (loanID) references loan(loanID) on delete cascade
);

-- Trigger to change assigned employee to the customer to recent joined employee before deleting the employee data
DROP TRIGGER IF EXISTS `bank`.`employee_BEFORE_DELETE`;

DELIMITER $$
USE `bank`$$
CREATE DEFINER = CURRENT_USER TRIGGER `bank`.`employee_BEFORE_DELETE` BEFORE DELETE ON `employee` FOR EACH ROW
BEGIN
	update customer set employeeID = (select max(employeeID) from employee) where employeeID = old.employeeID; 
END$$
DELIMITER ;

-- Trigger to insert payment when new loan is sanctioned
DROP TRIGGER IF EXISTS `bank`.`loan_AFTER_INSERT`;

DELIMITER $$
USE `bank`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `bank`.`loan_AFTER_INSERT` AFTER INSERT ON `loan` FOR EACH ROW
BEGIN
	insert into `payment` (`paymentDate`,`paymentAmount`,`remarks`,`loanID`) values (new.sanctionDate,new.amount,'Loan Sanctioned',new.loanID);
END$$
DELIMITER ;
