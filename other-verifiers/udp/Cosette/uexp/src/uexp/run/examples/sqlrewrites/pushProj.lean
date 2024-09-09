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
forall ( Γ scm_sx: Schema) (rel_y: relation scm_sx) (rel_x: relation scm_sx) (sx_a : Column int scm_sx) (sx_k : Column int scm_sx) ,
denoteSQL ((SELECT1 (right⋅left⋅sx_a) FROM1 (product (table rel_x) (table rel_y)) WHERE (equal (uvariable (right⋅left⋅sx_k)) (uvariable (right⋅right⋅sx_k)))) :SQL Γ _) 
= 
denoteSQL ((SELECT1 (right⋅left⋅left) FROM1 (product ((SELECT1 (combine (right⋅sx_a) (right⋅sx_k)) FROM1 (table rel_x) )) (table rel_y)) WHERE (equal (uvariable (right⋅left⋅right)) (uvariable (right⋅right⋅sx_k)))) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



