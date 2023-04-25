create database QLBH;
use QLBH;
create table Customer(
	cID int primary key ,
    `Name` varchar(25),
    cAge tinyint
); 
create table `Order`(
	oID int primary key,
    cID int ,
    oDate datetime,
    oTotalPrice int ,
    foreign key (cID) references Customer(cID)
);
create table `Product`(
	pID int primary key ,
    pName varchar(25),
    pPrice int
);
create table `OrderDetail`(
	oID int ,
    pID int ,
    odQTY int,
    foreign key (oID) references `Order`(oID),
    foreign key (pID) references Product(pID)
);
-- 1.Tạo cơ sở dữ liệu
insert into Customer values (1,"Minh Quan",10),(2,"Ngoc Oanh",20),(3,"Hong Ha",50);
insert into `Order` values (1,1,"2006-3-21",null),(2,2,"2006-3-23",null),(3,1,"2006-3-16",null);
insert into Product values (1,"May Giat",3),(2,"Tu Lanh",5),(3,"Dieu Hoa",7),(4,"Quat",1),(5,"Bep Dien",2);
insert into OrderDetail values (1,1,3),(1,3,7),(1,4,2),(2,1,1),(3,1,8),(2,5,4),(2,3,3);

-- 2. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn
-- trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa
-- đơn mới
select * from `Order`;
-- 3. Hiển thị tên và giá của các sản phẩm có giá cao nhất 
select pName , pPrice from Product where pPrice = (select max(pPrice) from Product);
select * from product;
-- 4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản
-- phẩm được mua bởi các khách đó 
select  c.Name, p.pName
from customer c join `order` o on c.cID=o.cID 
join orderdetail od on o.oID=od.oID 
join product p on p.pId=od.pID;
-- 5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
select `name` from customer where cID not in (select cId from `Order`);

-- 6. Hiển thị chi tiết của từng hóa đơn
select o.oID,o.oDate,od.odQTY,p.pName,p.pPrice
from `order` o join orderdetail od on o.oID=od.oID 
join product p on p.pID=od.pID;
-- 7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn (giá một
-- hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng xuất hiện
-- trong hóa đơn. Giá bán của từng loại được tính = odQTY*pPrice) 
select o.oId,o.oDate, sum((p.pPrice*od.odQTy)) as `Total`
from `order` o join orderdetail od on o.oID=od.oID
join product p on p.pID=od.pID group by oID;

-- 8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị
create view  Sales as select sum(p.pPrice * od.odQTY) as `Sales` 
from `Order` o join `Orderdetail` od on o.oID = od.oID
 join product p on od.pID = p.pID;
 select *from Sales;
-- 9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng.
alter table orderdetail drop foreign key orderdetail_ibfk_1;
alter table orderdetail drop foreign key orderdetail_ibfk_2;
alter table `order` drop foreign key order_ibfk_1;
alter table Customer drop primary key;
alter table `Order` drop primary key;
alter table `Product` drop primary key;

-- 10.Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa
-- mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo: .
create trigger cusUpdate after update on customer 
for each row  update `Order` set cID = new.cID where cID = old.cID;
set foreign_key_checks = 0;
 update Customer set cID = 1 where cAge = 10;
select * from customer;
select * from `Order`;
 set foreign_key_checks = 1;

-- 11. Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của 
-- một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên 
-- vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong 
-- bảng OrderDetail
DELIMITER //

CREATE PROCEDURE delProduct (IN deletePName VARCHAR(255))
BEGIN
    DELETE FROM OrderDetail WHERE pID = (SELECT pID FROM Product WHERE pName = deletePName);
    DELETE FROM Product WHERE pName = deletePName;
END//

DELIMITER ;
call delProduct("quat");
select * from product;

