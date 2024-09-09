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
forall ( Γ scm_s: Schema) (rel_r: relation scm_s) (s_a1 : Column int scm_s) (s_a2 : Column int scm_s) (s_a3 : Column int scm_s) ,
denoteSQL (DISTINCT (SELECT * FROM1 (table rel_r) WHERE (and (equal (uvariable (right⋅s_a1)) (uvariable (right⋅s_a2))) (equal (uvariable (right⋅s_a2)) (uvariable (right⋅s_a3))))) :SQL Γ _) 
= 
denoteSQL (DISTINCT (SELECT * FROM1 (table rel_r) WHERE (and (equal (uvariable (right⋅s_a1)) (uvariable (right⋅s_a2))) (equal (uvariable (right⋅s_a1)) (uvariable (right⋅s_a3))))) :SQL Γ _)  :=
begin
    intros,
    try { unfold_all_denotations },
    try { funext, simp },
    try { TDP' ucongr },
    try { UDP },

end 



