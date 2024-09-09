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
 
variable integer_1: const datatypes.int 


theorem rule: 
forall ( Γ scm_s2 scm_s1: Schema) (rel_r2: relation scm_s2) (rel_r1: relation scm_s1) (s2_y : Column int scm_s2)  (s1_x : Column int scm_s1) (s1_y : Column int scm_s1) ,
denoteSQL (DISTINCT (SELECT1 (right⋅left⋅s1_x) FROM1 (product (table rel_r1) (table rel_r2)) WHERE (and (equal (uvariable (right⋅left⋅s1_y)) (uvariable (right⋅right⋅s2_y))) (equal (uvariable (right⋅left⋅s1_x)) (constantExpr integer_1)))) :SQL Γ _) 
= 
denoteSQL (DISTINCT (SELECT1 (right⋅left⋅s1_x) FROM1 (product (table rel_r1) (product (table rel_r1) (table rel_r2))) WHERE (and (and (equal (uvariable (right⋅left⋅s1_x)) (uvariable (right⋅right⋅left⋅s1_x))) (equal (uvariable (right⋅left⋅s1_y)) (uvariable (right⋅right⋅right⋅s2_y)))) (equal (uvariable (right⋅left⋅s1_x)) (constantExpr integer_1)))) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



