SELECT * FROM department.account;

create table account(accountNumber int primary key auto_increment, customerName varchar(30) not null, balance numeric(10,2));
insert into account(customerName,balance) values("supriya",10000);
insert into account(customerName,balance) values("Manu",20000);

create table account_update(accountNumber int,
customerName varchar(30) not null,
changed_id timestamp,
old_balance numeric(10,2) not null,
transaction_amount numeric(10,2) not null,
transactionType varchar(30) not null,
new_balance numeric(10,2) not null);

delimiter $$
 create trigger account_update_debit  before update on account for each row
 begin
 if(old.balance>new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance,transaction_amount)
    values(old.accountNumber,old.customerName, now(),'debit', old.balance, new.balance, old.balance-new.balance);
    END IF;
end$$

delimiter **
 create trigger account_update_credit  before update on account for each row
 begin
 if(old.balance<new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance, transaction_amount)
    values(old.accountNumber,old.customerName, now(),'credit', old.balance, new.balance, new.balance-old.balance);
    END IF;
end**

update account set balance=balance-1000 where accountNumber=1;
update account set balance=balance+5000 where accountNumber=1;

delimiter %%
create procedure sumWithdrawal(in acc_No int, out totalDebit numeric(10,2), out totalCredit numeric(10,2))
begin
select sum(old_balance-new_balance) into totalDebit from account_update where  transactionType='debit' and accountNumber=acc_No;
select sum(new_balance-old_balance) into totalCredit from account_update where  transactionType='credit' and accountNumber=acc_No;
end %%

call sumWithdrawal(1, @totalDebit,@totalCredit);

select @totalDebit,@totalCredit

create Event myevent
on schedule at current_timestamp+interval 30 second
do
call sumWithdrawal(1, @totalDebit,@totalCredit);

drop event  myevent;

