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
forall ( Γ scm_s2 scm_s1: Schema) (rel_r2: relation scm_s2) (rel_r1: relation scm_s1)  (pred_b : Pred (Γ++scm_s2)),
denoteSQL ((SELECT * FROM1 (product (table rel_r1) ((SELECT * FROM1 (table rel_r2) WHERE (castPred (combine left (right)) pred_b)))) ) :SQL Γ _) 
= 
denoteSQL ((SELECT * FROM1 (product (table rel_r1) (table rel_r2)) WHERE (castPred (combine left (right⋅right)) pred_b)) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



