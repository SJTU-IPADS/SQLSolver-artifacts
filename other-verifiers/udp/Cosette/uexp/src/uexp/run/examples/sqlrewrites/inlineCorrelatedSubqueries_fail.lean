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
forall ( Γ scm_s: Schema) (rel_a: relation scm_s) (s_c : Column int scm_s) ,
denoteSQL ((SELECT * FROM1 (table rel_a) WHERE (EXISTS (SELECT * FROM1 (table rel_a) WHERE (equal (uvariable (left⋅right⋅s_c)) (uvariable (right⋅s_c)))))) :SQL Γ _) 
= 
denoteSQL ((SELECT * FROM1 (table rel_a) ) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



