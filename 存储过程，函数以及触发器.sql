--存储过程：获取所有员工的薪水
--SYS_REFCURSOR:系统提供的动态游标类型 可以是IN 可以是OUT 也可以是 IN OUT
CREATE OR REPLACE PROCEDURE get_sals(sals OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN sals FOR SELECT ename,sal FROM emp;
END;
--调用
DECLARE
  vc_name emp.ename%TYPE;
  n_sal emp.sal%TYPE;
  sals SYS_REFCURSOR;
BEGIN
  get_sals(sals);
  LOOP
    FETCH sals INTO vc_name,n_sal;
    EXIT WHEN sals%NOTFOUND;
    dbms_output.put_line(vc_name||':'||n_sal);
  END LOOP;
  CLOSE sals;
END;


--将游标类型作为输入参数类型
CREATE OR REPLACE PROCEDURE get_sals2(sals IN SYS_REFCURSOR)
AS
  vc_name emp.ename%TYPE;
  n_sal emp.sal%TYPE;
BEGIN
   LOOP
    FETCH sals INTO vc_name,n_sal;
    EXIT WHEN sals%NOTFOUND;
    dbms_output.put_line(vc_name||':'||n_sal);
  END LOOP;
  CLOSE sals;
END;

DECLARE
  sals SYS_REFCURSOR;
BEGIN
  OPEN sals FOR SELECT ename,sal FROM emp;
  get_sals2(sals);
END;

--使用存储过程获取所有部门信息


--游标和事务的使用
--根据雇员编号查询到雇员，然后根据你输入的工资，来修改员工工资
--要求：员工工资要在现有所有员工的工资范围内
CREATE OR REPLACE PROCEDURE upd_sal(ID NUMBER,n_sal NUMBER)
AS
 n_maxsal emp.sal%TYPE;
 n_minsal emp.sal%TYPE;
 e_emp emp%ROWTYPE;
BEGIN
  --查询获取最高、最低工资
  SELECT MAX(sal),MIN(sal) INTO n_maxsal,n_minsal FROM empbak;
  --判断雇员是否存在
  SELECT * INTO e_emp FROM empbak WHERE empno=ID;
  IF n_sal>=n_minsal AND n_sal<=n_maxsal THEN
    UPDATE empbak SET sal=n_sal WHERE empno=ID;
  ELSE 
    raise_application_error(-20000,'输入的工资值不符合要求');
  END IF;
  COMMIT;
  dbms_output.put_line('修改成功');
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有指定的雇员，请重新输入');
    ROLLBACK;
END;

DECLARE
  exception20000 EXCEPTION;
  PRAGMA EXCEPTION_INIT(exception20000,-20000);
BEGIN
  upd_sal(7787,4000);
  
EXCEPTION
  WHEN exception20000 THEN
    dbms_output.put_line('输入的工资值不符合要求');
    ROLLBACK;
END;

CREATE TABLE empbak AS SELECT * FROM emp;
SELECT * FROM empbak;

--函数：根据部门编号获取部门名称
CREATE OR REPLACE FUNCTION get_dname(ID NUMBER)
--声明时，必须指定返回值类型（不需要大小）
RETURN VARCHAR2 AS
  vc_name dept.dname%TYPE;
BEGIN
  SELECT dname INTO vc_name FROM dept WHERE deptno=ID;
  --可执行部分也必须有至少一个return语句，返回声明类型的变量；
  RETURN vc_name;
END;
--在PL/SQL块中调用（不能作为独立的语句使用）
DECLARE
  vc_name VARCHAR2(20);
BEGIN
  vc_name := get_dname(20);--不能作为独立的语句使用
  dbms_output.put_line(vc_name);  
END;
--在SQL中调用函数
SELECT ename,get_dname(deptno) FROM emp;

