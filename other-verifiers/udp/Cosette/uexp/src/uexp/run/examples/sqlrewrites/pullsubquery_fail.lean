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
forall ( Γ scm_sb scm_sa: Schema) (rel_b: relation scm_sb) (rel_a: relation scm_sa)  (pred_b1 : Pred (Γ++scm_sa++scm_sb)) (pred_b0 : Pred (Γ++scm_sb)),
denoteSQL ((SELECT * FROM1 (product (table rel_a) ((SELECT * FROM1 (table rel_b) WHERE (castPred (combine left (right)) pred_b0)))) WHERE (castPred (combine left (combine (right⋅left) (right⋅right))) pred_b1)) :SQL Γ _) 
= 
denoteSQL ((SELECT * FROM1 (product (table rel_a) (table rel_b)) WHERE (and (castPred (combine left (combine (right⋅left) (right⋅right))) pred_b1) (castPred (combine left (right⋅right)) pred_b0))) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



