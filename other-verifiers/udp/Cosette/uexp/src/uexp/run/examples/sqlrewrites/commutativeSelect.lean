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
forall ( Γ scm_s: Schema) (rel_r: relation scm_s) (pred_b2 : Pred (Γ++scm_s)) (pred_b1 : Pred (Γ++scm_s)),
denoteSQL ((SELECT * FROM1 ((SELECT * FROM1 (table rel_r) WHERE (castPred (combine left (right)) pred_b1))) WHERE (castPred (combine left (right)) pred_b2)) :SQL Γ _) 
= 
denoteSQL ((SELECT * FROM1 ((SELECT * FROM1 (table rel_r) WHERE (castPred (combine left (right)) pred_b2))) WHERE (castPred (combine left (right)) pred_b1)) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



