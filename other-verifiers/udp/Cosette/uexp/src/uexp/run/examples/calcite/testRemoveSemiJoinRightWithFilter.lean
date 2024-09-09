import ..sql
import ..tactics
import ..u_semiring
import ..extra_constants
import ..meta.TDP
import ..meta.canonize
import ..meta.ucongr
import ..meta.cosette_tactics
import ..meta.SDP
import ..meta.UDP
 
open Expr 
open Proj 
open Pred 
open SQL 
open tree 
open binary_operators
 
notation `int` := datatypes.int 
 

variable str_foo_: const datatypes.int 

theorem rule: 
forall ( Γ scm_dept scm_emp: Schema) (rel_dept: relation scm_dept) (rel_emp: relation scm_emp) (dept_deptno : Column int scm_dept) (dept_name : Column int scm_dept) (emp_empno : Column int scm_emp) (emp_ename : Column int scm_emp) (emp_job : Column int scm_emp) (emp_mgr : Column int scm_emp) (emp_hiredate : Column int scm_emp) (emp_comm : Column int scm_emp) (emp_sal : Column int scm_emp) (emp_deptno : Column int scm_emp) (emp_slacker : Column int scm_emp),
denoteSQL ((SELECT1 (right⋅left⋅emp_ename) FROM1 (product (table rel_emp) (product (table rel_dept) (table rel_emp))) WHERE (and (and (equal (uvariable (right⋅left⋅emp_deptno)) (uvariable (right⋅right⋅left⋅dept_deptno))) (equal (uvariable (right⋅right⋅left⋅dept_deptno)) (uvariable (right⋅right⋅right⋅emp_deptno)))) (equal (uvariable (right⋅right⋅left⋅dept_name)) (constantExpr str_foo_)))) :SQL Γ _) 
= 
denoteSQL ((SELECT1 (right⋅left⋅emp_ename) FROM1 (product (table rel_emp) (product ((SELECT * FROM1 (table rel_dept) WHERE (equal (uvariable (right⋅dept_name)) (constantExpr str_foo_)))) (table rel_emp))) WHERE (and (equal (uvariable (right⋅left⋅emp_deptno)) (uvariable (right⋅right⋅left⋅dept_deptno))) (equal (uvariable (right⋅right⋅left⋅dept_deptno)) (uvariable (right⋅right⋅right⋅emp_deptno))))) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



