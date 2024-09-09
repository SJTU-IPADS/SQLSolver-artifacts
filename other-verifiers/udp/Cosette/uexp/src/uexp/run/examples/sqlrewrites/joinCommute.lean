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
 


theorem rule: 
forall ( Γ scm_s2 scm_s1: Schema) (rel_b: relation scm_s2) (rel_a: relation scm_s1) (s2_b1 : Column int scm_s2) (s2_b2 : Column int scm_s2) (s1_a1 : Column int scm_s1) (s1_a2 : Column int scm_s1),
denoteSQL ((SELECT1 (combine (right⋅left⋅s1_a1) (combine (right⋅left⋅s1_a2) (combine (right⋅right⋅s2_b1) (right⋅right⋅s2_b2)))) FROM1 (product (table rel_a) (table rel_b)) WHERE (equal (uvariable (right⋅left⋅s1_a1)) (uvariable (right⋅right⋅s2_b1)))) :SQL Γ _) 
= 
denoteSQL ((SELECT1 (combine (right⋅right⋅s1_a1) (combine (right⋅right⋅s1_a2) (combine (right⋅left⋅s2_b1) (right⋅left⋅s2_b2)))) FROM1 (product (table rel_b) (table rel_a)) WHERE (equal (uvariable (right⋅right⋅s1_a1)) (uvariable (right⋅left⋅s2_b1)))) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



