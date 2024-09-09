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
 
variable integer_10: const datatypes.int 


theorem rule: 
forall ( Γ scm_dept: Schema) (rel_dept: relation scm_dept) (dept_deptno : Column int scm_dept) (dept_name : Column int scm_dept),
denoteSQL ((SELECT1 (right⋅dept_name) FROM1 ((SELECT * FROM1 (table rel_dept) WHERE (equal (uvariable (right⋅dept_deptno)) (constantExpr integer_10)))) WHERE (equal (uvariable (right⋅dept_deptno)) (constantExpr integer_10))) :SQL Γ _) 
= 
denoteSQL ((SELECT1 (right⋅dept_name) FROM1 (table rel_dept) WHERE (equal (uvariable (right⋅dept_deptno)) (constantExpr integer_10))) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



