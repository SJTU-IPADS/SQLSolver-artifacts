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
forall ( Γ scm_s: Schema) (rel_r: relation scm_s) ,
denoteSQL (DISTINCT (SELECT1 (right⋅left⋅star) FROM1 (product (table rel_r) (table rel_r)) ) :SQL Γ _) 
= 
denoteSQL (DISTINCT (SELECT1 (right⋅star) FROM1 (table rel_r) ) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



