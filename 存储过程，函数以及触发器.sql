--�洢���̣���ȡ����Ա����нˮ
--SYS_REFCURSOR:ϵͳ�ṩ�Ķ�̬�α����� ������IN ������OUT Ҳ������ IN OUT
CREATE OR REPLACE PROCEDURE get_sals(sals OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN sals FOR SELECT ename,sal FROM emp;
END;
--����
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


--���α�������Ϊ�����������
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

--ʹ�ô洢���̻�ȡ���в�����Ϣ


--�α�������ʹ��
--���ݹ�Ա��Ų�ѯ����Ա��Ȼ�����������Ĺ��ʣ����޸�Ա������
--Ҫ��Ա������Ҫ����������Ա���Ĺ��ʷ�Χ��
CREATE OR REPLACE PROCEDURE upd_sal(ID NUMBER,n_sal NUMBER)
AS
 n_maxsal emp.sal%TYPE;
 n_minsal emp.sal%TYPE;
 e_emp emp%ROWTYPE;
BEGIN
  --��ѯ��ȡ��ߡ���͹���
  SELECT MAX(sal),MIN(sal) INTO n_maxsal,n_minsal FROM empbak;
  --�жϹ�Ա�Ƿ����
  SELECT * INTO e_emp FROM empbak WHERE empno=ID;
  IF n_sal>=n_minsal AND n_sal<=n_maxsal THEN
    UPDATE empbak SET sal=n_sal WHERE empno=ID;
  ELSE 
    raise_application_error(-20000,'����Ĺ���ֵ������Ҫ��');
  END IF;
  COMMIT;
  dbms_output.put_line('�޸ĳɹ�');
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('û��ָ���Ĺ�Ա������������');
    ROLLBACK;
END;

DECLARE
  exception20000 EXCEPTION;
  PRAGMA EXCEPTION_INIT(exception20000,-20000);
BEGIN
  upd_sal(7787,4000);
  
EXCEPTION
  WHEN exception20000 THEN
    dbms_output.put_line('����Ĺ���ֵ������Ҫ��');
    ROLLBACK;
END;

CREATE TABLE empbak AS SELECT * FROM emp;
SELECT * FROM empbak;

--���������ݲ��ű�Ż�ȡ��������
CREATE OR REPLACE FUNCTION get_dname(ID NUMBER)
--����ʱ������ָ������ֵ���ͣ�����Ҫ��С��
RETURN VARCHAR2 AS
  vc_name dept.dname%TYPE;
BEGIN
  SELECT dname INTO vc_name FROM dept WHERE deptno=ID;
  --��ִ�в���Ҳ����������һ��return��䣬�����������͵ı�����
  RETURN vc_name;
END;
--��PL/SQL���е��ã�������Ϊ���������ʹ�ã�
DECLARE
  vc_name VARCHAR2(20);
BEGIN
  vc_name := get_dname(20);--������Ϊ���������ʹ��
  dbms_output.put_line(vc_name);  
END;
--��SQL�е��ú���
SELECT ename,get_dname(deptno) FROM emp;

