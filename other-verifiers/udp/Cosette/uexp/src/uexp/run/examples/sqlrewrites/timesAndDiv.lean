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
forall ( Γ scm_s: Schema) (rel_r: relation scm_s) (s_a : Column int scm_s) (s_b : Column int scm_s),
denoteSQL ((SELECT1 (combine (e2p (binaryExpr add_ (uvariable (right⋅s_a)) (uvariable (right⋅s_b)))) (e2p (binaryExpr divide_ (uvariable (right⋅s_a)) (uvariable (right⋅s_b))))) FROM1 (table rel_r) ) :SQL Γ _) 
= 
denoteSQL ((SELECT1 (combine (e2p (binaryExpr add_ (uvariable (right⋅s_a)) (uvariable (right⋅s_b)))) (e2p (binaryExpr divide_ (uvariable (right⋅s_a)) (uvariable (right⋅s_b))))) FROM1 (table rel_r) ) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



