namespace gapt

open tactic expr

namespace lk

lemma LogicalAxiom {a} (main1 : a) (main2 : ¬a) : false := main2 main1
lemma BottomAxiom (main : false) : false := main
lemma TopAxiom (main : ¬true) : false := main ⟨⟩
lemma ReflexivityAxiom {α : Type} {a : α} (main : a ≠ a) : false := main (eq.refl a)
lemma NegLeftRule {a} (main : ¬a) (aux : ¬¬a) : false := aux main
lemma NegRightRule {a} (main : ¬¬a) (aux : ¬a) : false := main aux
lemma AndLeftRule {a b} (main : a ∧ b) (aux : a → b → false) : false :=
aux main.left main.right
lemma AndRightRule {a b} (main : ¬(a ∧ b)) (aux1 : ¬¬a) (aux2 : ¬¬b) : false :=
aux1 $ λa, aux2 $ λb, main ⟨a,b⟩
lemma OrLeftRule {a b} (main : a ∨ b) (aux1 : ¬a) (aux2 : ¬b) : false :=
begin cases main, contradiction, contradiction end
lemma OrRightRule {a b} (main : ¬(a ∨ b)) (aux : ¬a → ¬b → false) : false :=
aux (main ∘ or.inl) (main ∘ or.inr)
lemma ImpLeftRule {a b} (main : a → b) (aux1 : ¬¬a) (aux2 : ¬b) : false := aux1 (aux2 ∘ main)
lemma ImpRightRule {a b : Prop} (main : ¬(a → b)) (aux : a → ¬b → false) : false :=
main (classical.by_contradiction ∘ aux)
lemma ForallLeftRule {α} {P : α → Prop} (t) (main : ∀x, P x) (aux : ¬P t) : false := aux (main t)
lemma ForallRightRule {α} {P : α → Prop} (main : ¬∀x, P x) (aux : Πx, ¬P x → false) : false :=
begin apply main, intro x, apply classical.by_contradiction, intro, apply aux, assumption end
lemma ExistsLeftRule {α} {P : α → Prop} (main : ∃x, P x) (aux : Πx, P x → false) : false :=
begin cases main, apply aux, assumption end
lemma ExistsRightRule {α} {P : α → Prop} (t) (main : ¬∃x, P x) (aux : ¬¬P t) : false :=
begin apply aux, intro hp, apply main, existsi t, assumption end
lemma EqualityLeftRule1 {α} (c : α → Prop) (t s) (main1 : t=s) (main2 : c s) (aux : ¬c t) : false :=
begin apply aux, rw main1, assumption end
lemma EqualityRightRule1 {α} (c : α → Prop) (t s) (main1 : t=s) (main2 : ¬c s) (aux : ¬¬c t) : false :=
begin apply aux, rw main1, assumption end
lemma EqualityLeftRule2 {α} (c : α → Prop) (t s) (main1 : s=t) (main2 : c s) (aux : ¬c t) : false :=
EqualityLeftRule1 c t s main1.symm main2 aux
lemma EqualityRightRule2 {α} (c : α → Prop) (t s) (main1 : s=t) (main2 : ¬c s) (aux : ¬¬c t) : false :=
EqualityRightRule1 c t s main1.symm main2 aux
lemma CutRule (a : Prop) (aux1 : ¬¬a) (aux2 : ¬a) : false := aux1 aux2

lemma unpack_target_disj.cons {a b} (next : ¬a → b) : a ∨ b :=
classical.by_cases or.inl (or.inr ∘ next)
lemma unpack_target_disj.singleton {a} : ¬¬a → a := classical.by_contradiction
private meta def unpack_target_disj : list name → command
| [] := skip
| [h] := do tgt ← target,
            apply $ app (const ``gapt.lk.unpack_target_disj.singleton []) tgt,
            intro h, skip
| (h::hs) := do tgt ← target,
                a ← return $ tgt.app_fn.app_arg,
                b ← return $ tgt.app_arg,
                apply $ app_of_list (const ``gapt.lk.unpack_target_disj.cons []) [a, b],
                intro h,
                unpack_target_disj hs

meta def sequent_formula_to_hyps (ant suc : list name) : command := do
intro_lst ant, unpack_target_disj suc

end lk

end gapt

noncomputable theory

namespace gapt_export

def all {a : Type} (P : a -> Prop) := ∀x, P x

constant i : Type

constant difference : (i -> (i -> i))

constant b : i

constant a1 : i

constant product : (i -> (i -> i))

constant quotient : (i -> (i -> i))

constant d : (i -> (i -> (i -> Prop)))

constant b1 : i

constant c2 : i

constant c1 : i

constant c : i

constant a : i

constant m : (i -> (i -> (i -> Prop)))

constant b2 : i

lemma lk_proof : ((∀ B : i, (∀ A : i, ((quotient (product A B) B) = A))) -> ((∀ X3 : i, (∀ X4 : i, (∀ X5 : i, (and ((m X3 X4 X5) -> ((product (product X3 X4) (product X4 X5)) = (product X3 X5))) (((product (product X3 X4) (product X4 X5)) = (product X3 X5)) -> (m X3 X4 X5)))))) -> ((∀ B : i, (∀ A : i, ((product (quotient A B) B) = A))) -> ((∀ B : i, (∀ A : i, ((product (product (product A B) B) (product B (product B A))) = B))) -> ((∀ X0 : i, (∀ X1 : i, (∀ X2 : i, (and ((d X0 X1 X2) -> ((product X0 X1) = (product X1 X2))) (((product X0 X1) = (product X1 X2)) -> (d X0 X1 X2)))))) -> ((∀ A : i, ((product A A) = A)) -> ((∀ D : i, (∀ C : i, (∀ B : i, (∀ A : i, ((product (product A B) (product C D)) = (product (product A C) (product B D))))))) -> ((∀ B : i, (∀ A : i, ((product A (difference A B)) = B))) -> ((∀ B : i, (∀ A : i, ((difference A (product A B)) = B))) -> ((d a b c1) -> ((d a b1 c) -> ((d a1 b2 c1) -> ((d a1 b c) -> ((d a1 b1 c2) -> (m b1 b b2))))))))))))))) :=
by (((((((((gapt.lk.sequent_formula_to_hyps [`hyp.h_0, `hyp.h_1, `hyp.h_2, `hyp.h_3, `hyp.h_4, `hyp.h_5, `hyp.h_6, `hyp.h_7, `hyp.h_8, `hyp.h_9, `hyp.h_10, `hyp.h_11, `hyp.h_12, `hyp.h_13] [`hyp.h_14] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_0)) >>
(tactic.intro_lst [`hyp.h_15] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_0))) >>
((tactic.intro_lst [`hyp.h_16] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_0)) >>
(tactic.intro_lst [`hyp.h_17] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_0)))) >>
(((tactic.intro_lst [`hyp.h_18] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_0)) >>
(tactic.intro_lst [`hyp.h_19] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_0))) >>
((tactic.intro_lst [`hyp.h_20] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (quotient c b)) hyp.h_20)) >>
(tactic.intro_lst [`hyp.h_21] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (quotient (product b (quotient b1 b)) b)) hyp.h_20))))) >>
((((tactic.intro_lst [`hyp.h_22] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a hyp.h_20)) >>
(tactic.intro_lst [`hyp.h_23] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (quotient (quotient b1 b) b)) hyp.h_20))) >>
((tactic.intro_lst [`hyp.h_24] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (quotient c1 b)) hyp.h_20)) >>
(tactic.intro_lst [`hyp.h_25] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (quotient (product b b1) b)) hyp.h_20)))) >>
(((tactic.intro_lst [`hyp.h_26] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (quotient b1 b)) hyp.h_20)) >>
(tactic.intro_lst [`hyp.h_27] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_20))) >>
((tactic.intro_lst [`hyp.h_28] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 (quotient c2 b1)) hyp.h_19)) >>
(tactic.intro_lst [`hyp.h_29] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a hyp.h_19) >>
tactic.intro_lst [`hyp.h_30]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 (quotient c b1)) hyp.h_19) >>
tactic.intro_lst [`hyp.h_31]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_19) >>
tactic.intro_lst [`hyp.h_32])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference (difference b1 b) b) hyp.h_19) >>
tactic.intro_lst [`hyp.h_33]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference (difference (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_18) >>
tactic.intro_lst [`hyp.h_34]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) (quotient b2 (difference b1 b))) hyp.h_18) >>
tactic.intro_lst [`hyp.h_35]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (quotient (product (difference b1 b) b1) b)) hyp.h_17) >>
tactic.intro_lst [`hyp.h_36])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_17) >>
tactic.intro_lst [`hyp.h_37]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (quotient (quotient (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2))) hyp.h_16) >>
tactic.intro_lst [`hyp.h_38])))) >>
((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (quotient (product (product (difference b1 b) b2) (quotient (difference b1 b) (product (difference b1 b) b2))) (product (difference b1 b) b2))) hyp.h_16) >>
tactic.intro_lst [`hyp.h_39]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (quotient (product (product (difference b1 b) b2) (difference b1 b)) (product (difference b1 b) b2))) hyp.h_16) >>
tactic.intro_lst [`hyp.h_40])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (quotient (difference b1 b) (product (difference b1 b) b2))) hyp.h_16) >>
tactic.intro_lst [`hyp.h_41]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b2 (quotient (difference b2 (product (difference b1 b) b2)) b2)) hyp.h_15) >>
tactic.intro_lst [`hyp.h_42]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_15) >>
tactic.intro_lst [`hyp.h_43]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b2 (quotient c1 b2)) hyp.h_15) >>
tactic.intro_lst [`hyp.h_44])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_15) >>
tactic.intro_lst [`hyp.h_45]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_1) >>
tactic.intro_lst [`hyp.h_46] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_46))))))) >>
((((((tactic.intro_lst [`hyp.h_47] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_47)) >>
(tactic.intro_lst [`hyp.h_48] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_2))) >>
((tactic.intro_lst [`hyp.h_49] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_2)) >>
(tactic.intro_lst [`hyp.h_50] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_2)))) >>
(((tactic.intro_lst [`hyp.h_51] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_2)) >>
(tactic.intro_lst [`hyp.h_52] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_2))) >>
((tactic.intro_lst [`hyp.h_53] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (product b b1)) hyp.h_53)) >>
(tactic.intro_lst [`hyp.h_54] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_53))))) >>
((((tactic.intro_lst [`hyp.h_55] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c1 hyp.h_53)) >>
(tactic.intro_lst [`hyp.h_56] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_53))) >>
((tactic.intro_lst [`hyp.h_57] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient b1 b) hyp.h_53)) >>
(tactic.intro_lst [`hyp.h_58] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b1) hyp.h_53)))) >>
(((tactic.intro_lst [`hyp.h_59] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference (product b1 b) b) hyp.h_53)) >>
(tactic.intro_lst [`hyp.h_60] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_52))) >>
((tactic.intro_lst [`hyp.h_61] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c2 hyp.h_52)) >>
(tactic.intro_lst [`hyp.h_62] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_52) >>
tactic.intro_lst [`hyp.h_63]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_51) >>
tactic.intro_lst [`hyp.h_64]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_50) >>
tactic.intro_lst [`hyp.h_65])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (difference b1 b)) hyp.h_50) >>
tactic.intro_lst [`hyp.h_66]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference (product (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_50) >>
tactic.intro_lst [`hyp.h_67]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (quotient (difference b1 b) (product (difference b1 b) b2))) hyp.h_50) >>
tactic.intro_lst [`hyp.h_68]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (product (product (difference b1 b) b2) (difference b1 b))) hyp.h_50) >>
tactic.intro_lst [`hyp.h_69])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference b1 b) (product (difference b1 b) b2)) hyp.h_50) >>
tactic.intro_lst [`hyp.h_70]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b2 (product (difference b1 b) b2)) hyp.h_49) >>
tactic.intro_lst [`hyp.h_71])))) >>
((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule c1 hyp.h_49) >>
tactic.intro_lst [`hyp.h_72]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_3) >>
tactic.intro_lst [`hyp.h_73])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_3) >>
tactic.intro_lst [`hyp.h_74]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_3) >>
tactic.intro_lst [`hyp.h_75]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference b1 b) (product (difference b1 b) b2)) hyp.h_75) >>
tactic.intro_lst [`hyp.h_76]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (quotient (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_75) >>
tactic.intro_lst [`hyp.h_77])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient b1 b) hyp.h_74) >>
tactic.intro_lst [`hyp.h_78]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (quotient b1 b) b) hyp.h_74) >>
tactic.intro_lst [`hyp.h_79] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_73)))))))) >>
(((((((tactic.intro_lst [`hyp.h_80] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_73)) >>
(tactic.intro_lst [`hyp.h_81] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_4))) >>
((tactic.intro_lst [`hyp.h_82] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a hyp.h_4)) >>
(tactic.intro_lst [`hyp.h_83] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_83)))) >>
(((tactic.intro_lst [`hyp.h_84] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_83)) >>
(tactic.intro_lst [`hyp.h_85] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c1 hyp.h_85))) >>
((tactic.intro_lst [`hyp.h_86] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_84)) >>
(tactic.intro_lst [`hyp.h_87] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_82))))) >>
((((tactic.intro_lst [`hyp.h_88] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_82)) >>
(tactic.intro_lst [`hyp.h_89] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_82))) >>
((tactic.intro_lst [`hyp.h_90] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c1 hyp.h_90)) >>
(tactic.intro_lst [`hyp.h_91] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_89)))) >>
(((tactic.intro_lst [`hyp.h_92] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c2 hyp.h_88)) >>
(tactic.intro_lst [`hyp.h_93] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_5))) >>
((tactic.intro_lst [`hyp.h_94] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c b) hyp.h_5)) >>
(tactic.intro_lst [`hyp.h_95] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_5) >>
tactic.intro_lst [`hyp.h_96]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c b1) hyp.h_5) >>
tactic.intro_lst [`hyp.h_97]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_5) >>
tactic.intro_lst [`hyp.h_98])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_5) >>
tactic.intro_lst [`hyp.h_99]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_5) >>
tactic.intro_lst [`hyp.h_100]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_5) >>
tactic.intro_lst [`hyp.h_101]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_6) >>
tactic.intro_lst [`hyp.h_102])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c b) hyp.h_6) >>
tactic.intro_lst [`hyp.h_103]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_6) >>
tactic.intro_lst [`hyp.h_104])))) >>
((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c b1) hyp.h_6) >>
tactic.intro_lst [`hyp.h_105]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_6) >>
tactic.intro_lst [`hyp.h_106])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_6) >>
tactic.intro_lst [`hyp.h_107]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule c2 hyp.h_6) >>
tactic.intro_lst [`hyp.h_108]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_6) >>
tactic.intro_lst [`hyp.h_109]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference c c) hyp.h_6) >>
tactic.intro_lst [`hyp.h_110])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_6) >>
tactic.intro_lst [`hyp.h_111]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient c b) hyp.h_111) >>
tactic.intro_lst [`hyp.h_112] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product b (quotient b1 b)) b) hyp.h_111))))))) >>
((((((tactic.intro_lst [`hyp.h_113] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient c1 b) hyp.h_111)) >>
(tactic.intro_lst [`hyp.h_114] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient b1 b) hyp.h_111))) >>
((tactic.intro_lst [`hyp.h_115] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_111)) >>
(tactic.intro_lst [`hyp.h_116] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product b b1) b) hyp.h_111)))) >>
(((tactic.intro_lst [`hyp.h_117] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (quotient b1 b) b) hyp.h_111)) >>
(tactic.intro_lst [`hyp.h_118] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_118))) >>
((tactic.intro_lst [`hyp.h_119] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_119)) >>
(tactic.intro_lst [`hyp.h_120] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_117))))) >>
((((tactic.intro_lst [`hyp.h_121] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_121)) >>
(tactic.intro_lst [`hyp.h_122] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_116))) >>
((tactic.intro_lst [`hyp.h_123] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_123)) >>
(tactic.intro_lst [`hyp.h_124] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_115)))) >>
(((tactic.intro_lst [`hyp.h_125] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_125)) >>
(tactic.intro_lst [`hyp.h_126] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b a1) hyp.h_114))) >>
((tactic.intro_lst [`hyp.h_127] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product (difference b1 b) b1) b) hyp.h_114)) >>
(tactic.intro_lst [`hyp.h_128] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_114) >>
tactic.intro_lst [`hyp.h_129]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_129) >>
tactic.intro_lst [`hyp.h_130]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_128) >>
tactic.intro_lst [`hyp.h_131])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_127) >>
tactic.intro_lst [`hyp.h_132]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_113) >>
tactic.intro_lst [`hyp.h_133]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_133) >>
tactic.intro_lst [`hyp.h_134]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_112) >>
tactic.intro_lst [`hyp.h_135])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product (difference b1 b) b1) b) hyp.h_112) >>
tactic.intro_lst [`hyp.h_136]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_112) >>
tactic.intro_lst [`hyp.h_137] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_137))))) >>
((((tactic.intro_lst [`hyp.h_138] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_136)) >>
(tactic.intro_lst [`hyp.h_139] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_135))) >>
((tactic.intro_lst [`hyp.h_140] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_110)) >>
(tactic.intro_lst [`hyp.h_141] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_141)))) >>
(((tactic.intro_lst [`hyp.h_142] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_142)) >>
(tactic.intro_lst [`hyp.h_143] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_109))) >>
((tactic.intro_lst [`hyp.h_144] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient c b1) hyp.h_109)) >>
(tactic.intro_lst [`hyp.h_145] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference (quotient (difference (product b1 b) b) b) b) hyp.h_109) >>
tactic.intro_lst [`hyp.h_146])))))))) >>
((((((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient c2 b1) hyp.h_109) >>
tactic.intro_lst [`hyp.h_147]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_109) >>
tactic.intro_lst [`hyp.h_148])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient b b1) hyp.h_109) >>
tactic.intro_lst [`hyp.h_149]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_149) >>
tactic.intro_lst [`hyp.h_150]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_150) >>
tactic.intro_lst [`hyp.h_151]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule c1 hyp.h_148) >>
tactic.intro_lst [`hyp.h_152])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_152) >>
tactic.intro_lst [`hyp.h_153]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_147) >>
tactic.intro_lst [`hyp.h_154])))) >>
((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_147) >>
tactic.intro_lst [`hyp.h_155]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_155) >>
tactic.intro_lst [`hyp.h_156])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_154) >>
tactic.intro_lst [`hyp.h_157]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_146) >>
tactic.intro_lst [`hyp.h_158]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference (product b1 b) b) b) hyp.h_158) >>
tactic.intro_lst [`hyp.h_159]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_145) >>
tactic.intro_lst [`hyp.h_160])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_145) >>
tactic.intro_lst [`hyp.h_161]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_145) >>
tactic.intro_lst [`hyp.h_162] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_162)))))) >>
(((((tactic.intro_lst [`hyp.h_163] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_161)) >>
(tactic.intro_lst [`hyp.h_164] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_160))) >>
((tactic.intro_lst [`hyp.h_165] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c1 hyp.h_144)) >>
(tactic.intro_lst [`hyp.h_166] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_166)))) >>
(((tactic.intro_lst [`hyp.h_167] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_108)) >>
(tactic.intro_lst [`hyp.h_168] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_168))) >>
((tactic.intro_lst [`hyp.h_169] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a hyp.h_169)) >>
(tactic.intro_lst [`hyp.h_170] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_107))))) >>
((((tactic.intro_lst [`hyp.h_171] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference (quotient (difference (product (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_107)) >>
(tactic.intro_lst [`hyp.h_172] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient b2 (difference b1 b)) hyp.h_107))) >>
((tactic.intro_lst [`hyp.h_173] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_173)) >>
(tactic.intro_lst [`hyp.h_174] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_174)))) >>
(((tactic.intro_lst [`hyp.h_175] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_172)) >>
(tactic.intro_lst [`hyp.h_176] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference (product (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_176))) >>
((tactic.intro_lst [`hyp.h_177] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient b b1) hyp.h_171)) >>
(tactic.intro_lst [`hyp.h_178] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_178) >>
tactic.intro_lst [`hyp.h_179])))))) >>
((((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_106) >>
tactic.intro_lst [`hyp.h_180]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_180) >>
tactic.intro_lst [`hyp.h_181])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_181) >>
tactic.intro_lst [`hyp.h_182]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c b1) hyp.h_105) >>
tactic.intro_lst [`hyp.h_183]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_183) >>
tactic.intro_lst [`hyp.h_184]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule a hyp.h_184) >>
tactic.intro_lst [`hyp.h_185])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product (product (difference b1 b) b2) (quotient (difference b1 b) (product (difference b1 b) b2))) (product (difference b1 b) b2)) hyp.h_104) >>
tactic.intro_lst [`hyp.h_186]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product (product (difference b1 b) b2) (difference b1 b)) (product (difference b1 b) b2)) hyp.h_104) >>
tactic.intro_lst [`hyp.h_187])))) >>
((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference b1 b) (product (difference b1 b) b2)) hyp.h_104) >>
tactic.intro_lst [`hyp.h_188]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (quotient (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_104) >>
tactic.intro_lst [`hyp.h_189])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_189) >>
tactic.intro_lst [`hyp.h_190]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_190) >>
tactic.intro_lst [`hyp.h_191]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_188) >>
tactic.intro_lst [`hyp.h_192]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_192) >>
tactic.intro_lst [`hyp.h_193])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_187) >>
tactic.intro_lst [`hyp.h_194]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_194) >>
tactic.intro_lst [`hyp.h_195] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_186)))))) >>
(((((tactic.intro_lst [`hyp.h_196] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_196)) >>
(tactic.intro_lst [`hyp.h_197] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c b) hyp.h_103))) >>
((tactic.intro_lst [`hyp.h_198] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_198)) >>
(tactic.intro_lst [`hyp.h_199] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_199)))) >>
(((tactic.intro_lst [`hyp.h_200] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b2 (difference b1 b)) hyp.h_102)) >>
(tactic.intro_lst [`hyp.h_201] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference b2 (product (difference b1 b) b2)) b2) hyp.h_102))) >>
((tactic.intro_lst [`hyp.h_202] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient c1 b2) hyp.h_102)) >>
(tactic.intro_lst [`hyp.h_203] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_102) >>
tactic.intro_lst [`hyp.h_204])))) >>
((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (quotient b b1) (difference b1 b)) hyp.h_102) >>
tactic.intro_lst [`hyp.h_205]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 b1) hyp.h_205) >>
tactic.intro_lst [`hyp.h_206])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 b1) hyp.h_206) >>
tactic.intro_lst [`hyp.h_207]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 b1) hyp.h_204) >>
tactic.intro_lst [`hyp.h_208]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 (quotient b b1)) hyp.h_208) >>
tactic.intro_lst [`hyp.h_209]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b2 (difference b1 b)) hyp.h_203) >>
tactic.intro_lst [`hyp.h_210])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_203) >>
tactic.intro_lst [`hyp.h_211]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_211) >>
tactic.intro_lst [`hyp.h_212] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_210)))))))) >>
(((((((tactic.intro_lst [`hyp.h_213] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_202)) >>
(tactic.intro_lst [`hyp.h_214] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_214))) >>
((tactic.intro_lst [`hyp.h_215] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_201)) >>
(tactic.intro_lst [`hyp.h_216] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_216)))) >>
(((tactic.intro_lst [`hyp.h_217] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_7)) >>
(tactic.intro_lst [`hyp.h_218] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_7))) >>
((tactic.intro_lst [`hyp.h_219] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b2 b) hyp.h_7)) >>
(tactic.intro_lst [`hyp.h_220] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_7))))) >>
((((tactic.intro_lst [`hyp.h_221] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_7)) >>
(tactic.intro_lst [`hyp.h_222] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b1 hyp.h_222))) >>
((tactic.intro_lst [`hyp.h_223] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference (product b1 b) b) b) hyp.h_222)) >>
(tactic.intro_lst [`hyp.h_224] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_221)))) >>
(((tactic.intro_lst [`hyp.h_225] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_220)) >>
(tactic.intro_lst [`hyp.h_226] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_219))) >>
((tactic.intro_lst [`hyp.h_227] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference (product (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_218)) >>
(tactic.intro_lst [`hyp.h_228] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_218) >>
tactic.intro_lst [`hyp.h_229]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_8) >>
tactic.intro_lst [`hyp.h_230]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient c b) hyp.h_8) >>
tactic.intro_lst [`hyp.h_231])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c b) hyp.h_8) >>
tactic.intro_lst [`hyp.h_232]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) b2) hyp.h_8) >>
tactic.intro_lst [`hyp.h_233]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference (quotient (difference (product (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (difference b1 b)) hyp.h_8) >>
tactic.intro_lst [`hyp.h_234]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b2 (difference b1 b)) b2) hyp.h_8) >>
tactic.intro_lst [`hyp.h_235])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_8) >>
tactic.intro_lst [`hyp.h_236]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference b2 (product (difference b1 b) b2)) b2) hyp.h_8) >>
tactic.intro_lst [`hyp.h_237])))) >>
((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (difference (difference b1 b) (product b2 b)) (difference b1 b)) hyp.h_8) >>
tactic.intro_lst [`hyp.h_238]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (product (product (difference b1 b) b2) (quotient (quotient (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)))) hyp.h_8) >>
tactic.intro_lst [`hyp.h_239])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b1 b) (difference c c)) hyp.h_8) >>
tactic.intro_lst [`hyp.h_240]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b c2) hyp.h_8) >>
tactic.intro_lst [`hyp.h_241]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference b b) b) hyp.h_8) >>
tactic.intro_lst [`hyp.h_242]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (product b (quotient (quotient b1 b) b))) hyp.h_8) >>
tactic.intro_lst [`hyp.h_243])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b (product b (quotient b1 b))) hyp.h_8) >>
tactic.intro_lst [`hyp.h_244]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product c1 b1) hyp.h_8) >>
tactic.intro_lst [`hyp.h_245] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (difference b1 b) b2) (product (product (difference b1 b) b2) (quotient (difference b1 b) (product (difference b1 b) b2)))) hyp.h_8))))))) >>
((((((tactic.intro_lst [`hyp.h_246] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (difference (quotient (difference (product b1 b) b) b) b) b1) hyp.h_8)) >>
(tactic.intro_lst [`hyp.h_247] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_8))) >>
((tactic.intro_lst [`hyp.h_248] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_248)) >>
(tactic.intro_lst [`hyp.h_249] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product b (product b b1)) b) hyp.h_248)))) >>
(((tactic.intro_lst [`hyp.h_250] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (quotient (difference (product b1 b) b) b) b) hyp.h_247)) >>
(tactic.intro_lst [`hyp.h_251] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (quotient (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_246))) >>
((tactic.intro_lst [`hyp.h_252] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product a1 c) hyp.h_245)) >>
(tactic.intro_lst [`hyp.h_253] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (quotient b1 b) b) b) hyp.h_244))))) >>
((((tactic.intro_lst [`hyp.h_254] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (quotient (quotient b1 b) b) b) b) hyp.h_243)) >>
(tactic.intro_lst [`hyp.h_255] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_242))) >>
((tactic.intro_lst [`hyp.h_256] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 c) hyp.h_241)) >>
(tactic.intro_lst [`hyp.h_257] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product b1 c) hyp.h_240)))) >>
(((tactic.intro_lst [`hyp.h_258] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (product (quotient (quotient (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_239)) >>
(tactic.intro_lst [`hyp.h_259] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_238))) >>
((tactic.intro_lst [`hyp.h_260] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule b2 hyp.h_237)) >>
(tactic.intro_lst [`hyp.h_261] >>
tactic.interactive.apply ```(gapt.lk.ForallLeftRule c hyp.h_236) >>
tactic.intro_lst [`hyp.h_262]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.ForallLeftRule a1 hyp.h_235) >>
tactic.intro_lst [`hyp.h_263]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product (quotient (difference (product (difference b1 b) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) (product (difference b1 b) b2)) hyp.h_234) >>
tactic.intro_lst [`hyp.h_264])) >>
((tactic.interactive.apply ```(gapt.lk.ForallLeftRule (quotient (product (product (difference b1 b) b2) (product (product (difference b1 b) b2) (difference b1 b))) (product (difference b1 b) b2)) hyp.h_233) >>
tactic.intro_lst [`hyp.h_265]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (product a1 c) hyp.h_232) >>
tactic.intro_lst [`hyp.h_266]))) >>
(((tactic.interactive.apply ```(gapt.lk.ForallLeftRule b hyp.h_231) >>
tactic.intro_lst [`hyp.h_267]) >>
(tactic.interactive.apply ```(gapt.lk.ForallLeftRule (difference b1 b) hyp.h_230) >>
tactic.intro_lst [`hyp.h_268])) >>
((tactic.interactive.apply ```(gapt.lk.AndLeftRule hyp.h_93) >>
tactic.intro_lst [`hyp.h_269, `hyp.h_270]) >>
(tactic.interactive.apply ```(gapt.lk.AndLeftRule hyp.h_92) >>
tactic.intro_lst [`hyp.h_271, `hyp.h_272] >>
tactic.interactive.apply ```(gapt.lk.AndLeftRule hyp.h_91))))) >>
((((tactic.intro_lst [`hyp.h_273, `hyp.h_274] >>
tactic.interactive.apply ```(gapt.lk.AndLeftRule hyp.h_87)) >>
(tactic.intro_lst [`hyp.h_275, `hyp.h_276] >>
tactic.interactive.apply ```(gapt.lk.AndLeftRule hyp.h_86))) >>
((tactic.intro_lst [`hyp.h_277, `hyp.h_278] >>
tactic.interactive.apply ```(gapt.lk.AndLeftRule hyp.h_48)) >>
(tactic.intro_lst [`hyp.h_279, `hyp.h_280] >>
tactic.interactive.apply ```(gapt.lk.ImpLeftRule hyp.h_280)))) >>
(((tactic.intro_lst [`hyp.h_281] >>
tactic.interactive.apply ```(gapt.lk.ImpLeftRule hyp.h_277)) >>
(tactic.intro_lst [`hyp.h_282] >>
tactic.interactive.apply ```(gapt.lk.LogicalAxiom hyp.h_9 hyp.h_282))) >>
((tactic.intro_lst [`hyp.h_282] >>
tactic.interactive.apply ```(gapt.lk.ImpLeftRule hyp.h_275)) >>
(tactic.intro_lst [`hyp.h_283] >>
tactic.interactive.apply ```(gapt.lk.LogicalAxiom hyp.h_10 hyp.h_283) >>
tactic.intro_lst [`hyp.h_283]))))))))) >>
(((((((((tactic.interactive.apply ```(gapt.lk.ImpLeftRule hyp.h_273) >>
tactic.intro_lst [`hyp.h_284]) >>
(tactic.interactive.apply ```(gapt.lk.LogicalAxiom hyp.h_11 hyp.h_284) >>
tactic.intro_lst [`hyp.h_284])) >>
((tactic.interactive.apply ```(gapt.lk.ImpLeftRule hyp.h_271) >>
tactic.intro_lst [`hyp.h_285]) >>
(tactic.interactive.apply ```(gapt.lk.LogicalAxiom hyp.h_12 hyp.h_285) >>
tactic.intro_lst [`hyp.h_285]))) >>
(((tactic.interactive.apply ```(gapt.lk.ImpLeftRule hyp.h_269) >>
tactic.intro_lst [`hyp.h_286]) >>
(tactic.interactive.apply ```(gapt.lk.LogicalAxiom hyp.h_13 hyp.h_286) >>
tactic.intro_lst [`hyp.h_286])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference b x) = b)) b (product b b) hyp.h_101 hyp.h_249) >>
tactic.intro_lst [`hyp.h_287]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference a1 (product a1 (product x b))) = (product x b))) b (difference b b) hyp.h_287 hyp.h_256) >>
tactic.intro_lst [`hyp.h_288])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference a1 (product a1 x)) = x)) b (product b b) hyp.h_101 hyp.h_288) >>
tactic.intro_lst [`hyp.h_289]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference a1 x) = b)) (product b c) (product a1 b) hyp.h_285 hyp.h_289) >>
tactic.intro_lst [`hyp.h_290])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient x b1) = a)) (product b1 c) (product a b1) hyp.h_283 hyp.h_30) >>
tactic.intro_lst [`hyp.h_291]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 b1) x) = (product (product b1 (quotient c b1)) (product b1 b1)))) c (product (quotient c b1) b1) hyp.h_61 hyp.h_164) >>
tactic.intro_lst [`hyp.h_292]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x c) = (product (product b1 (quotient c b1)) x))) b1 (product b1 b1) hyp.h_100 hyp.h_292) >>
tactic.intro_lst [`hyp.h_293]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b1) = (product b1 (quotient c b1)))) (product b1 c) (product (product b1 (quotient c b1)) b1) hyp.h_293 hyp.h_31) >>
tactic.intro_lst [`hyp.h_294])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product b1 (quotient c b1)))) a (quotient (product b1 c) b1) hyp.h_291 hyp.h_294) >>
tactic.intro_lst [`hyp.h_295]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 (difference b1 b)) x) = (product (product b1 (quotient c b1)) (product (difference b1 b) b1)))) c (product (quotient c b1) b1) hyp.h_61 hyp.h_163) >>
tactic.intro_lst [`hyp.h_296] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x c) = (product (product b1 (quotient c b1)) (product (difference b1 b) b1)))) b (product b1 (difference b1 b)) hyp.h_223 hyp.h_296)))))) >>
(((((tactic.intro_lst [`hyp.h_297] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b c) = (product x (product (difference b1 b) b1)))) a (product b1 (quotient c b1)) hyp.h_295 hyp.h_297)) >>
(tactic.intro_lst [`hyp.h_298] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient x b) = a1)) (product b c) (product a1 b) hyp.h_285 hyp.h_28))) >>
((tactic.intro_lst [`hyp.h_299] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b b) x) = (product (product b (quotient c b)) (product b b)))) c (product (quotient c b) b) hyp.h_55 hyp.h_138)) >>
(tactic.intro_lst [`hyp.h_300] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x c) = (product (product b (quotient c b)) x))) b (product b b) hyp.h_101 hyp.h_300)))) >>
(((tactic.intro_lst [`hyp.h_301] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b) = (product b (quotient c b)))) (product b c) (product (product b (quotient c b)) b) hyp.h_301 hyp.h_21)) >>
(tactic.intro_lst [`hyp.h_302] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product b (quotient c b)))) a1 (quotient (product b c) b) hyp.h_299 hyp.h_302))) >>
((tactic.intro_lst [`hyp.h_303] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b c) x) = (product (product b (quotient c b)) (product c b)))) c (product (quotient c b) b) hyp.h_55 hyp.h_140)) >>
(tactic.intro_lst [`hyp.h_304] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b c) c) = (product x (product c b)))) a1 (product b (quotient c b)) hyp.h_303 hyp.h_304))))) >>
((((tactic.intro_lst [`hyp.h_305] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product c (product c b))) = c)) (product a1 (product c b)) (product (product b c) c) hyp.h_305 hyp.h_81)) >>
(tactic.intro_lst [`hyp.h_306] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product a1 c) x) = (product (product a1 (product c b)) (product c (product c b))))) (product c b) (product (product c b) (product c b)) hyp.h_95 hyp.h_200))) >>
((tactic.intro_lst [`hyp.h_307] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product a1 c) (product c b)) = x)) c (product (product a1 (product c b)) (product c (product c b))) hyp.h_306 hyp.h_307)) >>
(tactic.intro_lst [`hyp.h_308] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product a1 c) x) = (product c b))) c (product (product a1 c) (product c b)) hyp.h_308 hyp.h_266)))) >>
(((tactic.intro_lst [`hyp.h_309] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b b) x) = (product (product b c) (product b c)))) c (product c c) hyp.h_98 hyp.h_182)) >>
(tactic.intro_lst [`hyp.h_310] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x c) = (product (product b c) (product b c)))) b (product b b) hyp.h_101 hyp.h_310))) >>
((tactic.intro_lst [`hyp.h_311] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b c) x) = (product (product b a1) (product c b)))) (product b c) (product a1 b) hyp.h_285 hyp.h_124)) >>
(tactic.intro_lst [`hyp.h_312] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, (x = (product (product b a1) (product c b)))) (product b c) (product (product b c) (product b c)) hyp.h_311 hyp.h_312) >>
tactic.intro_lst [`hyp.h_313])))))) >>
((((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b c) = (product (product b a1) x))) (difference (product a1 c) c) (product c b) hyp.h_309 hyp.h_313) >>
tactic.intro_lst [`hyp.h_314]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient x b) = a)) (product b c1) (product a b) hyp.h_282 hyp.h_23) >>
tactic.intro_lst [`hyp.h_315])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient c1 b) b)) = (product (product b (quotient c1 b)) x))) b (product b b) hyp.h_101 hyp.h_130) >>
tactic.intro_lst [`hyp.h_316]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b x) = (product (product b (quotient c1 b)) b))) c1 (product (quotient c1 b) b) hyp.h_56 hyp.h_316) >>
tactic.intro_lst [`hyp.h_317]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b) = (product b (quotient c1 b)))) (product b c1) (product (product b (quotient c1 b)) b) hyp.h_317 hyp.h_25) >>
tactic.intro_lst [`hyp.h_318]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product b (quotient c1 b)))) a (quotient (product b c1) b) hyp.h_315 hyp.h_318) >>
tactic.intro_lst [`hyp.h_319])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference b x) = (quotient c b))) a1 (product b (quotient c b)) hyp.h_303 hyp.h_267) >>
tactic.intro_lst [`hyp.h_320]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x b) = c)) (difference b a1) (quotient c b) hyp.h_320 hyp.h_55) >>
tactic.intro_lst [`hyp.h_321])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b (difference b a1)) (product (quotient c1 b) b)) = (product (product b (quotient c1 b)) x))) c (product (difference b a1) b) hyp.h_321 hyp.h_132) >>
tactic.intro_lst [`hyp.h_322]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient c1 b) b)) = (product (product b (quotient c1 b)) c))) a1 (product b (difference b a1)) hyp.h_225 hyp.h_322) >>
tactic.intro_lst [`hyp.h_323])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product a1 (product (quotient c1 b) b)) = (product x c))) a (product b (quotient c1 b)) hyp.h_319 hyp.h_323) >>
tactic.intro_lst [`hyp.h_324]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product a1 x) = (product a c))) c1 (product (quotient c1 b) b) hyp.h_56 hyp.h_324) >>
tactic.intro_lst [`hyp.h_325]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 c) x) = (product (product b1 (quotient c b1)) (product c b1)))) c (product (quotient c b1) b1) hyp.h_61 hyp.h_165) >>
tactic.intro_lst [`hyp.h_326]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b1 c) c) = (product x (product c b1)))) a (product b1 (quotient c b1)) hyp.h_295 hyp.h_326) >>
tactic.intro_lst [`hyp.h_327])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product c (product c b1))) = c)) (product a (product c b1)) (product (product b1 c) c) hyp.h_327 hyp.h_80) >>
tactic.intro_lst [`hyp.h_328]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product a c) (product (product c b1) (product c b1))) = x)) c (product (product a (product c b1)) (product c (product c b1))) hyp.h_328 hyp.h_185) >>
tactic.intro_lst [`hyp.h_329] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product a c) x) = c)) (product c b1) (product (product c b1) (product c b1)) hyp.h_97 hyp.h_329)))))) >>
(((((tactic.intro_lst [`hyp.h_330] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x (product c b1)) = c)) (product a1 c1) (product a c) hyp.h_325 hyp.h_330)) >>
(tactic.intro_lst [`hyp.h_331] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (product a1 c) x) = (product c1 b1))) (product (product a1 c1) (product c b1)) (product (product a1 c) (product c1 b1)) hyp.h_167 hyp.h_253))) >>
((tactic.intro_lst [`hyp.h_332] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product a1 c) x) = (product c1 b1))) c (product (product a1 c1) (product c b1)) hyp.h_331 hyp.h_332)) >>
(tactic.intro_lst [`hyp.h_333] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product b c2)) = (product (product a b) (product b1 c2)))) (product b1 c) (product a b1) hyp.h_283 hyp.h_170)))) >>
(((tactic.intro_lst [`hyp.h_334] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b1 c) (product b c2)) = (product (product a b) x))) (product a1 b1) (product b1 c2) hyp.h_286 hyp.h_334)) >>
(tactic.intro_lst [`hyp.h_335] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 c) (product b c2)) = (product x (product a1 b1)))) (product b c1) (product a b) hyp.h_282 hyp.h_335))) >>
((tactic.intro_lst [`hyp.h_336] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product b1 c) x) = (product b c2))) (product (product b c1) (product a1 b1)) (product (product b1 c) (product b c2)) hyp.h_336 hyp.h_257)) >>
(tactic.intro_lst [`hyp.h_337] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product b1 c) x) = (product b c2))) (product (product b a1) (product c1 b1)) (product (product b c1) (product a1 b1)) hyp.h_153 hyp.h_337))))) >>
((((tactic.intro_lst [`hyp.h_338] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (product b1 c) (product (product b a1) x)) = (product b c2))) (difference (product a1 c) c) (product c1 b1) hyp.h_333 hyp.h_338)) >>
(tactic.intro_lst [`hyp.h_339] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (product b1 c) x) = (product b c2))) (product b c) (product (product b a1) (difference (product a1 c) c)) hyp.h_314 hyp.h_339))) >>
((tactic.intro_lst [`hyp.h_340] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference c x) = c)) c (product c c) hyp.h_98 hyp.h_262)) >>
(tactic.intro_lst [`hyp.h_341] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 c) (product (difference b1 b) x)) = (product (product b1 (difference b1 b)) (product c x)))) c (difference c c) hyp.h_341 hyp.h_143)))) >>
(((tactic.intro_lst [`hyp.h_342] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 c) (product (difference b1 b) c)) = (product x (product c c)))) b (product b1 (difference b1 b)) hyp.h_223 hyp.h_342)) >>
(tactic.intro_lst [`hyp.h_343] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 c) (product (difference b1 b) c)) = (product b x))) c (product c c) hyp.h_98 hyp.h_343))) >>
((tactic.intro_lst [`hyp.h_344] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product b1 c) (product (product b1 c) (product (difference b1 b) x))) = (product (difference b1 b) x))) c (difference c c) hyp.h_341 hyp.h_258)) >>
(tactic.intro_lst [`hyp.h_345] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product b1 c) x) = (product (difference b1 b) c))) (product b c) (product (product b1 c) (product (difference b1 b) c)) hyp.h_344 hyp.h_345) >>
tactic.intro_lst [`hyp.h_346]))))))) >>
(((((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x c) = (difference b1 b))) (difference (product b1 c) (product b c)) (product (difference b1 b) c) hyp.h_346 hyp.h_37) >>
tactic.intro_lst [`hyp.h_347]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient x c) = (difference b1 b))) (product b c2) (difference (product b1 c) (product b c)) hyp.h_340 hyp.h_347) >>
tactic.intro_lst [`hyp.h_348])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 b1) x) = (product (product b1 (quotient c2 b1)) (product b1 b1)))) c2 (product (quotient c2 b1) b1) hyp.h_62 hyp.h_157) >>
tactic.intro_lst [`hyp.h_349]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x c2) = (product (product b1 (quotient c2 b1)) x))) b1 (product b1 b1) hyp.h_100 hyp.h_349) >>
tactic.intro_lst [`hyp.h_350]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, (x = (product (product b1 (quotient c2 b1)) b1))) (product a1 b1) (product b1 c2) hyp.h_286 hyp.h_350) >>
tactic.intro_lst [`hyp.h_351]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b1) = (product b1 (quotient c2 b1)))) (product a1 b1) (product (product b1 (quotient c2 b1)) b1) hyp.h_351 hyp.h_29) >>
tactic.intro_lst [`hyp.h_352])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product b1 (quotient c2 b1)))) a1 (quotient (product a1 b1) b1) hyp.h_32 hyp.h_352) >>
tactic.intro_lst [`hyp.h_353]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 (difference b1 b)) x) = (product (product b1 (quotient c2 b1)) (product (difference b1 b) b1)))) c2 (product (quotient c2 b1) b1) hyp.h_62 hyp.h_156) >>
tactic.intro_lst [`hyp.h_354])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x c2) = (product (product b1 (quotient c2 b1)) (product (difference b1 b) b1)))) b (product b1 (difference b1 b)) hyp.h_223 hyp.h_354) >>
tactic.intro_lst [`hyp.h_355]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b c2) = (product x (product (difference b1 b) b1)))) a1 (product b1 (quotient c2 b1)) hyp.h_353 hyp.h_355) >>
tactic.intro_lst [`hyp.h_356])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b (quotient (product (difference b1 b) b1) b)) (product (quotient c b) b)) = (product (product b (quotient c b)) x))) (product (difference b1 b) b1) (product (quotient (product (difference b1 b) b1) b) b) hyp.h_59 hyp.h_139) >>
tactic.intro_lst [`hyp.h_357]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b (quotient (product (difference b1 b) b1) b)) (product x b)) = (product (product b x) (product (difference b1 b) b1)))) (difference b a1) (quotient c b) hyp.h_320 hyp.h_357) >>
tactic.intro_lst [`hyp.h_358]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b (quotient (product (difference b1 b) b1) b)) x) = (product (product b (difference b a1)) (product (difference b1 b) b1)))) c (product (difference b a1) b) hyp.h_321 hyp.h_358) >>
tactic.intro_lst [`hyp.h_359]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b (quotient (product (difference b1 b) b1) b)) c) = (product x (product (difference b1 b) b1)))) a1 (product b (difference b a1)) hyp.h_225 hyp.h_359) >>
tactic.intro_lst [`hyp.h_360])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b (quotient (product (difference b1 b) b1) b)) c) = x)) (product b c2) (product a1 (product (difference b1 b) b1)) hyp.h_356 hyp.h_360) >>
tactic.intro_lst [`hyp.h_361]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient x c) = (product b (quotient (product (difference b1 b) b1) b)))) (product b c2) (product (product b (quotient (product (difference b1 b) b1) b)) c) hyp.h_361 hyp.h_36) >>
tactic.intro_lst [`hyp.h_362] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product b (quotient (product (difference b1 b) b1) b)))) (difference b1 b) (quotient (product b c2) c) hyp.h_348 hyp.h_362)))))) >>
(((((tactic.intro_lst [`hyp.h_363] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b (quotient (product (difference b1 b) b1) b)) (product (quotient c1 b) b)) = (product x (product (quotient (product (difference b1 b) b1) b) b)))) a (product b (quotient c1 b)) hyp.h_319 hyp.h_131)) >>
(tactic.intro_lst [`hyp.h_364] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x (product (quotient c1 b) b)) = (product a (product (quotient (product (difference b1 b) b1) b) b)))) (difference b1 b) (product b (quotient (product (difference b1 b) b1) b)) hyp.h_363 hyp.h_364))) >>
((tactic.intro_lst [`hyp.h_365] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (difference b1 b) (product (quotient c1 b) b)) = (product a x))) (product (difference b1 b) b1) (product (quotient (product (difference b1 b) b1) b) b) hyp.h_59 hyp.h_365)) >>
(tactic.intro_lst [`hyp.h_366] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (difference b1 b) (product (quotient c1 b) b)) = x)) (product b c) (product a (product (difference b1 b) b1)) hyp.h_298 hyp.h_366)))) >>
(((tactic.intro_lst [`hyp.h_367] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (difference b1 b) x) = (product b c))) c1 (product (quotient c1 b) b) hyp.h_56 hyp.h_367)) >>
(tactic.intro_lst [`hyp.h_368] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient c1 b2) b2)) = (product (product b2 (quotient c1 b2)) x))) b2 (product b2 b2) hyp.h_94 hyp.h_212))) >>
((tactic.intro_lst [`hyp.h_369] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b2 x) = (product (product b2 (quotient c1 b2)) b2))) c1 (product (quotient c1 b2) b2) hyp.h_72 hyp.h_369)) >>
(tactic.intro_lst [`hyp.h_370] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, (x = (product (product b2 (quotient c1 b2)) b2))) (product a1 b2) (product b2 c1) hyp.h_284 hyp.h_370))))) >>
((((tactic.intro_lst [`hyp.h_371] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b2) = (product b2 (quotient c1 b2)))) (product a1 b2) (product (product b2 (quotient c1 b2)) b2) hyp.h_371 hyp.h_44)) >>
(tactic.intro_lst [`hyp.h_372] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product b2 (quotient c1 b2)))) a1 (quotient (product a1 b2) b2) hyp.h_45 hyp.h_372))) >>
((tactic.intro_lst [`hyp.h_373] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b2 (difference b2 (difference b1 b))) (product (quotient c1 b2) b2)) = (product x (product (difference b2 (difference b1 b)) b2)))) a1 (product b2 (quotient c1 b2)) hyp.h_373 hyp.h_213)) >>
(tactic.intro_lst [`hyp.h_374] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient c1 b2) b2)) = (product a1 (product (difference b2 (difference b1 b)) b2)))) (difference b1 b) (product b2 (difference b2 (difference b1 b))) hyp.h_227 hyp.h_374)))) >>
(((tactic.intro_lst [`hyp.h_375] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (difference b1 b) x) = (product a1 (product (difference b2 (difference b1 b)) b2)))) c1 (product (quotient c1 b2) b2) hyp.h_72 hyp.h_375)) >>
(tactic.intro_lst [`hyp.h_376] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference a1 x) = (product (difference b2 (difference b1 b)) b2))) (product (difference b1 b) c1) (product a1 (product (difference b2 (difference b1 b)) b2)) hyp.h_376 hyp.h_263))) >>
((tactic.intro_lst [`hyp.h_377] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 b2) (product (difference b2 (difference b1 b)) b2)) = (product x (product b2 b2)))) (difference b1 b) (product b2 (difference b2 (difference b1 b))) hyp.h_227 hyp.h_217)) >>
(tactic.intro_lst [`hyp.h_378] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (difference b2 (difference b1 b)) b2)) = (product (difference b1 b) x))) b2 (product b2 b2) hyp.h_94 hyp.h_378) >>
tactic.intro_lst [`hyp.h_379])))))) >>
((((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b2 x) = (product (difference b1 b) b2))) (difference a1 (product (difference b1 b) c1)) (product (difference b2 (difference b1 b)) b2) hyp.h_377 hyp.h_379) >>
tactic.intro_lst [`hyp.h_380]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b2) = (difference b1 b))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_43) >>
tactic.intro_lst [`hyp.h_381])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b2 (difference b2 x)) = x)) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_229) >>
tactic.intro_lst [`hyp.h_382]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (quotient (difference b2 x) b2) b2) = (difference b2 x))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_71) >>
tactic.intro_lst [`hyp.h_383]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient (difference b2 (product (difference b1 b) b2)) b2) b2)) = (product (product b2 (quotient (difference b2 (product (difference b1 b) b2)) b2)) x))) b2 (product b2 b2) hyp.h_94 hyp.h_215) >>
tactic.intro_lst [`hyp.h_384]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b2 (product (quotient (difference b2 x) b2) b2)) = (product (product b2 (quotient (difference b2 x) b2)) b2))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_384) >>
tactic.intro_lst [`hyp.h_385])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b2 x) = (product (product b2 (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2)) b2))) (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) (product (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2) b2) hyp.h_383 hyp.h_385) >>
tactic.intro_lst [`hyp.h_386]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product (product b2 (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2)) b2))) (product b2 (difference a1 (product (difference b1 b) c1))) (product b2 (difference b2 (product b2 (difference a1 (product (difference b1 b) c1))))) hyp.h_382 hyp.h_386) >>
tactic.intro_lst [`hyp.h_387])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient (product (product b2 (quotient (difference b2 x) b2)) b2) b2) = (product b2 (quotient (difference b2 x) b2)))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_42) >>
tactic.intro_lst [`hyp.h_388]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b2) = (product b2 (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2)))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2)) b2) hyp.h_387 hyp.h_388) >>
tactic.intro_lst [`hyp.h_389])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product b2 (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2)))) (difference b1 b) (quotient (product b2 (difference a1 (product (difference b1 b) c1))) b2) hyp.h_381 hyp.h_389) >>
tactic.intro_lst [`hyp.h_390]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference b2 (product b2 (quotient (difference b2 x) b2))) = (quotient (difference b2 x) b2))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_261) >>
tactic.intro_lst [`hyp.h_391]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference b2 x) = (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2))) (difference b1 b) (product b2 (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2)) hyp.h_390 hyp.h_391) >>
tactic.intro_lst [`hyp.h_392]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x b2) = (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))))) (difference b2 (difference b1 b)) (quotient (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))) b2) hyp.h_392 hyp.h_383) >>
tactic.intro_lst [`hyp.h_393])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, (x = (difference b2 (product b2 (difference a1 (product (difference b1 b) c1)))))) (difference a1 (product (difference b1 b) c1)) (product (difference b2 (difference b1 b)) b2) hyp.h_377 hyp.h_393) >>
tactic.intro_lst [`hyp.h_394]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference a1 x) = (difference b2 (product b2 (difference a1 x))))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_394) >>
tactic.intro_lst [`hyp.h_395] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (difference b2 (product b2 x)))) b (difference a1 (product b c)) hyp.h_290 hyp.h_395)))))) >>
(((((tactic.intro_lst [`hyp.h_396] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (difference b1 b) x) = b2)) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_268)) >>
(tactic.intro_lst [`hyp.h_397] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (difference b1 b) (product b2 (difference a1 x))) = b2)) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_397))) >>
((tactic.intro_lst [`hyp.h_398] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (difference b1 b) (product b2 x)) = b2)) b (difference a1 (product b c)) hyp.h_290 hyp.h_398)) >>
(tactic.intro_lst [`hyp.h_399] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (difference b1 b) x) = (product b2 b))) b2 (difference (difference b1 b) (product b2 b)) hyp.h_399 hyp.h_226)))) >>
(((tactic.intro_lst [`hyp.h_400] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (difference (difference (difference b1 b) x) x) (difference b1 b)) (difference b1 b)) = (difference (difference (difference b1 b) x) x))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_34)) >>
(tactic.intro_lst [`hyp.h_401] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (difference x (product b2 b)) (difference b1 b)) (difference b1 b)) = (difference x (product b2 b)))) b2 (difference (difference b1 b) (product b2 b)) hyp.h_399 hyp.h_401))) >>
((tactic.intro_lst [`hyp.h_402] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient (product x (difference b1 b)) (difference b1 b)) = x)) b (difference b2 (product b2 b)) hyp.h_396 hyp.h_402)) >>
(tactic.intro_lst [`hyp.h_403] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (quotient (difference b1 b) x) x) = (difference b1 b))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_65) >>
tactic.intro_lst [`hyp.h_404])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (quotient (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))) = (difference b1 b))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_404) >>
tactic.intro_lst [`hyp.h_405]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (quotient (difference b1 b) (product b2 x)) (product b2 x)) = (difference b1 b))) b (difference a1 (product b c)) hyp.h_290 hyp.h_405) >>
tactic.intro_lst [`hyp.h_406])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (quotient (quotient (difference b1 b) x) x) x) = (quotient (difference b1 b) x))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_70) >>
tactic.intro_lst [`hyp.h_407]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product (product (quotient (quotient (difference b1 b) x) x) x) x) (product x (product x (quotient (quotient (difference b1 b) x) x)))) = x)) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_77) >>
tactic.intro_lst [`hyp.h_408]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product x (product b2 b)) (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))))) = (product b2 b))) (quotient (difference b1 b) (product b2 b)) (product (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)) (product b2 b)) hyp.h_407 hyp.h_408) >>
tactic.intro_lst [`hyp.h_409]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))))) = (product b2 b))) (difference b1 b) (product (quotient (difference b1 b) (product b2 b)) (product b2 b)) hyp.h_406 hyp.h_409) >>
tactic.intro_lst [`hyp.h_410])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (product (product (quotient (quotient (difference b1 b) x) x) x) x) (product (product (product (quotient (quotient (difference b1 b) x) x) x) x) (product x (product x (quotient (quotient (difference b1 b) x) x))))) = (product x (product x (quotient (quotient (difference b1 b) x) x))))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_259) >>
tactic.intro_lst [`hyp.h_411]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (product (quotient (quotient (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product (product (product (quotient (quotient (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product (product b2 (difference a1 x)) (product (product b2 (difference a1 x)) (quotient (quotient (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))))))) = (product (product b2 (difference a1 x)) (product (product b2 (difference a1 x)) (quotient (quotient (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))))))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_411) >>
tactic.intro_lst [`hyp.h_412] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (product (quotient (quotient (difference b1 b) (product b2 x)) (product b2 x)) (product b2 x)) (product b2 x)) (product (product (product (quotient (quotient (difference b1 b) (product b2 x)) (product b2 x)) (product b2 x)) (product b2 x)) (product (product b2 x) (product (product b2 x) (quotient (quotient (difference b1 b) (product b2 x)) (product b2 x)))))) = (product (product b2 x) (product (product b2 x) (quotient (quotient (difference b1 b) (product b2 x)) (product b2 x)))))) b (difference a1 (product b c)) hyp.h_290 hyp.h_412))))))))) >>
((((((((tactic.intro_lst [`hyp.h_413] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product x (product b2 b)) (product (product x (product b2 b)) (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))))) = (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))))) (quotient (difference b1 b) (product b2 b)) (product (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)) (product b2 b)) hyp.h_407 hyp.h_413)) >>
(tactic.intro_lst [`hyp.h_414] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference x (product x (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))))) = (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))))) (difference b1 b) (product (quotient (difference b1 b) (product b2 b)) (product b2 b)) hyp.h_406 hyp.h_414))) >>
((tactic.intro_lst [`hyp.h_415] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (difference b1 b) x) = (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))))) (product b2 b) (product (difference b1 b) (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))))) hyp.h_410 hyp.h_415)) >>
(tactic.intro_lst [`hyp.h_416] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))))) b2 (difference (difference b1 b) (product b2 b)) hyp.h_399 hyp.h_416)))) >>
(((tactic.intro_lst [`hyp.h_417] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x x) = x)) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_96)) >>
(tactic.intro_lst [`hyp.h_418] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product x x) (product (quotient (quotient (difference b1 b) x) x) x)) = (product (product x (quotient (quotient (difference b1 b) x) x)) (product x x)))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_191))) >>
((tactic.intro_lst [`hyp.h_419] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1))))) = (product (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1))))) x))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (product b2 (difference a1 (product (difference b1 b) c1)))) hyp.h_418 hyp.h_419)) >>
(tactic.intro_lst [`hyp.h_420] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 (difference a1 x)) (product (quotient (quotient (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x)))) = (product (product (product b2 (difference a1 x)) (quotient (quotient (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x)))) (product b2 (difference a1 x))))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_420))))) >>
((((tactic.intro_lst [`hyp.h_421] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 x) (product (quotient (quotient (difference b1 b) (product b2 x)) (product b2 x)) (product b2 x))) = (product (product (product b2 x) (quotient (quotient (difference b1 b) (product b2 x)) (product b2 x))) (product b2 x)))) b (difference a1 (product b c)) hyp.h_290 hyp.h_421)) >>
(tactic.intro_lst [`hyp.h_422] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 b) x) = (product (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))) (product b2 b)))) (quotient (difference b1 b) (product b2 b)) (product (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)) (product b2 b)) hyp.h_407 hyp.h_422))) >>
((tactic.intro_lst [`hyp.h_423] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product x (quotient (quotient (difference b1 b) x) x)) x) x) = (product x (quotient (quotient (difference b1 b) x) x)))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_38)) >>
(tactic.intro_lst [`hyp.h_424] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x (product b2 b)) = (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))))) (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))) (product b2 b)) hyp.h_423 hyp.h_424)))) >>
(((tactic.intro_lst [`hyp.h_425] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product x (quotient (product x (quotient (difference b1 b) x)) x)) x) x) = (product x (quotient (product x (quotient (difference b1 b) x)) x)))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_39)) >>
(tactic.intro_lst [`hyp.h_426] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product (product b2 b) x) (product b2 b)) (product b2 b)) = (product (product b2 b) x))) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))) (quotient (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product b2 b)) hyp.h_425 hyp.h_426))) >>
((tactic.intro_lst [`hyp.h_427] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient (product x (product b2 b)) (product b2 b)) = x)) b2 (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))) hyp.h_417 hyp.h_427)) >>
(tactic.intro_lst [`hyp.h_428] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product (product (quotient (difference b1 b) x) x) x) (product x (product x (quotient (difference b1 b) x)))) = x)) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_76) >>
tactic.intro_lst [`hyp.h_429]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product x (product b2 b)) (product (product b2 b) (product (product b2 b) (quotient (difference b1 b) (product b2 b))))) = (product b2 b))) (difference b1 b) (product (quotient (difference b1 b) (product b2 b)) (product b2 b)) hyp.h_406 hyp.h_429) >>
tactic.intro_lst [`hyp.h_430]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (product (product (quotient (difference b1 b) x) x) x) (product (product (product (quotient (difference b1 b) x) x) x) (product x (product x (quotient (difference b1 b) x))))) = (product x (product x (quotient (difference b1 b) x))))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_252) >>
tactic.intro_lst [`hyp.h_431])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product x (product b2 (difference a1 (product (difference b1 b) c1)))) (product (product x (product b2 (difference a1 (product (difference b1 b) c1)))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))))))) = (product (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))))))) (difference b1 b) (product (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) hyp.h_404 hyp.h_431) >>
tactic.intro_lst [`hyp.h_432]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (difference b1 b) (product b2 (difference a1 x))) (product (product (difference b1 b) (product b2 (difference a1 x))) (product (product b2 (difference a1 x)) (product (product b2 (difference a1 x)) (quotient (difference b1 b) (product b2 (difference a1 x))))))) = (product (product b2 (difference a1 x)) (product (product b2 (difference a1 x)) (quotient (difference b1 b) (product b2 (difference a1 x))))))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_432) >>
tactic.intro_lst [`hyp.h_433]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (difference b1 b) (product b2 x)) (product (product (difference b1 b) (product b2 x)) (product (product b2 x) (product (product b2 x) (quotient (difference b1 b) (product b2 x)))))) = (product (product b2 x) (product (product b2 x) (quotient (difference b1 b) (product b2 x)))))) b (difference a1 (product b c)) hyp.h_290 hyp.h_433) >>
tactic.intro_lst [`hyp.h_434]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (difference b1 b) (product b2 b)) x) = (product (product b2 b) (product (product b2 b) (quotient (difference b1 b) (product b2 b)))))) (product b2 b) (product (product (difference b1 b) (product b2 b)) (product (product b2 b) (product (product b2 b) (quotient (difference b1 b) (product b2 b))))) hyp.h_430 hyp.h_434) >>
tactic.intro_lst [`hyp.h_435])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (quotient (product x (quotient (difference b1 b) x)) x) x) = (product x (quotient (difference b1 b) x)))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_68) >>
tactic.intro_lst [`hyp.h_436]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product x x) (product (quotient (product x (quotient (difference b1 b) x)) x) x)) = (product (product x (quotient (product x (quotient (difference b1 b) x)) x)) (product x x)))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_197) >>
tactic.intro_lst [`hyp.h_437])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1))))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1))))) = (product (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1))))) (product b2 (difference a1 (product (difference b1 b) c1))))) x))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (product b2 (difference a1 (product (difference b1 b) c1)))) hyp.h_418 hyp.h_437) >>
tactic.intro_lst [`hyp.h_438]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 (difference a1 x)) (product (quotient (product (product b2 (difference a1 x)) (quotient (difference b1 b) (product b2 (difference a1 x)))) (product b2 (difference a1 x))) (product b2 (difference a1 x)))) = (product (product (product b2 (difference a1 x)) (quotient (product (product b2 (difference a1 x)) (quotient (difference b1 b) (product b2 (difference a1 x)))) (product b2 (difference a1 x)))) (product b2 (difference a1 x))))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_438) >>
tactic.intro_lst [`hyp.h_439])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 x) (product (quotient (product (product b2 x) (quotient (difference b1 b) (product b2 x))) (product b2 x)) (product b2 x))) = (product (product (product b2 x) (quotient (product (product b2 x) (quotient (difference b1 b) (product b2 x))) (product b2 x))) (product b2 x)))) b (difference a1 (product b c)) hyp.h_290 hyp.h_439) >>
tactic.intro_lst [`hyp.h_440]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 b) x) = (product (product (product b2 b) (quotient (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product b2 b))) (product b2 b)))) (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product (quotient (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product b2 b)) (product b2 b)) hyp.h_436 hyp.h_440) >>
tactic.intro_lst [`hyp.h_441]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, (x = (product (product (product b2 b) (quotient (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product b2 b))) (product b2 b)))) (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product (product b2 b) (product (product b2 b) (quotient (difference b1 b) (product b2 b)))) hyp.h_435 hyp.h_441) >>
tactic.intro_lst [`hyp.h_442]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (difference b1 b) (product b2 b)) (product b2 b)) = (product (product (product b2 b) x) (product b2 b)))) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b))) (quotient (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product b2 b)) hyp.h_425 hyp.h_442) >>
tactic.intro_lst [`hyp.h_443])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (product (difference b1 b) (product b2 b)) (product b2 b)) = (product x (product b2 b)))) b2 (product (product b2 b) (product (product b2 b) (quotient (quotient (difference b1 b) (product b2 b)) (product b2 b)))) hyp.h_417 hyp.h_443) >>
tactic.intro_lst [`hyp.h_444]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product x x) (product (quotient (difference b1 b) x) x)) = (product (product x (quotient (difference b1 b) x)) (product x x)))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_193) >>
tactic.intro_lst [`hyp.h_445] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product (product b2 (difference a1 (product (difference b1 b) c1))) (product b2 (difference a1 (product (difference b1 b) c1)))) x) = (product (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1))))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (product b2 (difference a1 (product (difference b1 b) c1))))))) (difference b1 b) (product (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) hyp.h_404 hyp.h_445))))))) >>
((((((tactic.intro_lst [`hyp.h_446] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (difference b1 b)) = (product (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1))))) x))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (product b2 (difference a1 (product (difference b1 b) c1)))) hyp.h_418 hyp.h_446)) >>
(tactic.intro_lst [`hyp.h_447] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 (difference a1 x)) (difference b1 b)) = (product (product (product b2 (difference a1 x)) (quotient (difference b1 b) (product b2 (difference a1 x)))) (product b2 (difference a1 x))))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_447))) >>
((tactic.intro_lst [`hyp.h_448] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 x) (difference b1 b)) = (product (product (product b2 x) (quotient (difference b1 b) (product b2 x))) (product b2 x)))) b (difference a1 (product b c)) hyp.h_290 hyp.h_448)) >>
(tactic.intro_lst [`hyp.h_449] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product x (quotient (difference b1 b) x)) x) x) = (product x (quotient (difference b1 b) x)))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_41)))) >>
(((tactic.intro_lst [`hyp.h_450] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x (product b2 b)) = (product (product b2 b) (quotient (difference b1 b) (product b2 b))))) (product (product b2 b) (difference b1 b)) (product (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (product b2 b)) hyp.h_449 hyp.h_450)) >>
(tactic.intro_lst [`hyp.h_451] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (quotient (product x (difference b1 b)) x) x) = (product x (difference b1 b)))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_66))) >>
((tactic.intro_lst [`hyp.h_452] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product x x) (product (quotient (product x (difference b1 b)) x) x)) = (product (product x (quotient (product x (difference b1 b)) x)) (product x x)))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_195)) >>
(tactic.intro_lst [`hyp.h_453] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient (product (product b2 (difference a1 (product (difference b1 b) c1))) (difference b1 b)) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1))))) = (product (product (product b2 (difference a1 (product (difference b1 b) c1))) (quotient (product (product b2 (difference a1 (product (difference b1 b) c1))) (difference b1 b)) (product b2 (difference a1 (product (difference b1 b) c1))))) x))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (product b2 (difference a1 (product (difference b1 b) c1)))) hyp.h_418 hyp.h_453))))) >>
((((tactic.intro_lst [`hyp.h_454] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 (difference a1 x)) (product (quotient (product (product b2 (difference a1 x)) (difference b1 b)) (product b2 (difference a1 x))) (product b2 (difference a1 x)))) = (product (product (product b2 (difference a1 x)) (quotient (product (product b2 (difference a1 x)) (difference b1 b)) (product b2 (difference a1 x)))) (product b2 (difference a1 x))))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_454)) >>
(tactic.intro_lst [`hyp.h_455] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 x) (product (quotient (product (product b2 x) (difference b1 b)) (product b2 x)) (product b2 x))) = (product (product (product b2 x) (quotient (product (product b2 x) (difference b1 b)) (product b2 x))) (product b2 x)))) b (difference a1 (product b c)) hyp.h_290 hyp.h_455))) >>
((tactic.intro_lst [`hyp.h_456] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 b) x) = (product (product (product b2 b) (quotient (product (product b2 b) (difference b1 b)) (product b2 b))) (product b2 b)))) (product (product b2 b) (difference b1 b)) (product (quotient (product (product b2 b) (difference b1 b)) (product b2 b)) (product b2 b)) hyp.h_452 hyp.h_456)) >>
(tactic.intro_lst [`hyp.h_457] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b2 b) (product (product b2 b) (difference b1 b))) = (product (product (product b2 b) x) (product b2 b)))) (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (quotient (product (product b2 b) (difference b1 b)) (product b2 b)) hyp.h_451 hyp.h_457)))) >>
(((tactic.intro_lst [`hyp.h_458] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b2 b) (product (product b2 b) (difference b1 b))) = (product x (product b2 b)))) (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product (product b2 b) (product (product b2 b) (quotient (difference b1 b) (product b2 b)))) hyp.h_435 hyp.h_458)) >>
(tactic.intro_lst [`hyp.h_459] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product x (quotient (product x (difference b1 b)) x)) x) x) = (product x (quotient (product x (difference b1 b)) x)))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_40))) >>
((tactic.intro_lst [`hyp.h_460] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product (product b2 b) x) (product b2 b)) (product b2 b)) = (product (product b2 b) x))) (product (product b2 b) (quotient (difference b1 b) (product b2 b))) (quotient (product (product b2 b) (difference b1 b)) (product b2 b)) hyp.h_451 hyp.h_460)) >>
(tactic.intro_lst [`hyp.h_461] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient (product x (product b2 b)) (product b2 b)) = x)) (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product (product b2 b) (product (product b2 b) (quotient (difference b1 b) (product b2 b)))) hyp.h_435 hyp.h_461) >>
tactic.intro_lst [`hyp.h_462]))))) >>
(((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x (product b2 b)) = (difference (product (difference b1 b) (product b2 b)) (product b2 b)))) (product (product b2 b) (product (product b2 b) (difference b1 b))) (product (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product b2 b)) hyp.h_459 hyp.h_462) >>
tactic.intro_lst [`hyp.h_463]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (quotient (product x (product x (difference b1 b))) x) x) = (product x (product x (difference b1 b))))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_69) >>
tactic.intro_lst [`hyp.h_464])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (quotient (product x (product x (difference b1 b))) x) (product (quotient (product x (product x (difference b1 b))) x) x)) = x)) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_265) >>
tactic.intro_lst [`hyp.h_465]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (quotient (product (product b2 (difference a1 x)) (product (product b2 (difference a1 x)) (difference b1 b))) (product b2 (difference a1 x))) (product (quotient (product (product b2 (difference a1 x)) (product (product b2 (difference a1 x)) (difference b1 b))) (product b2 (difference a1 x))) (product b2 (difference a1 x)))) = (product b2 (difference a1 x)))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_465) >>
tactic.intro_lst [`hyp.h_466]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (quotient (product (product b2 x) (product (product b2 x) (difference b1 b))) (product b2 x)) (product (quotient (product (product b2 x) (product (product b2 x) (difference b1 b))) (product b2 x)) (product b2 x))) = (product b2 x))) b (difference a1 (product b c)) hyp.h_290 hyp.h_466) >>
tactic.intro_lst [`hyp.h_467]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (quotient (product (product b2 b) (product (product b2 b) (difference b1 b))) (product b2 b)) x) = (product b2 b))) (product (product b2 b) (product (product b2 b) (difference b1 b))) (product (quotient (product (product b2 b) (product (product b2 b) (difference b1 b))) (product b2 b)) (product b2 b)) hyp.h_464 hyp.h_467) >>
tactic.intro_lst [`hyp.h_468])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference x (product (product b2 b) (product (product b2 b) (difference b1 b)))) = (product b2 b))) (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (quotient (product (product b2 b) (product (product b2 b) (difference b1 b))) (product b2 b)) hyp.h_463 hyp.h_468) >>
tactic.intro_lst [`hyp.h_469]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (quotient (difference (product (difference b1 b) x) x) x) x) = (difference (product (difference b1 b) x) x))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_67) >>
tactic.intro_lst [`hyp.h_470] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (quotient (difference (product (difference b1 b) x) x) x) (difference (quotient (difference (product (difference b1 b) x) x) x) x)) = x)) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_228))))) >>
((((tactic.intro_lst [`hyp.h_471] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product (quotient (difference (product (difference b1 b) x) x) x) x) (product (difference (quotient (difference (product (difference b1 b) x) x) x) x) (difference b1 b))) = (product (product (quotient (difference (product (difference b1 b) x) x) x) (difference (quotient (difference (product (difference b1 b) x) x) x) x)) (product x (difference b1 b))))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_177)) >>
(tactic.intro_lst [`hyp.h_472] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product (difference (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (difference b1 b))) = (product x (product (product b2 (difference a1 (product (difference b1 b) c1))) (difference b1 b))))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (difference (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1))))) hyp.h_471 hyp.h_472))) >>
((tactic.intro_lst [`hyp.h_473] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (product (quotient (difference (product (difference b1 b) x) x) x) x) (product (product (quotient (difference (product (difference b1 b) x) x) x) x) (product (difference (quotient (difference (product (difference b1 b) x) x) x) x) (difference b1 b)))) = (product (difference (quotient (difference (product (difference b1 b) x) x) x) x) (difference b1 b)))) (product b2 (difference a1 (product (difference b1 b) c1))) (product (difference b1 b) b2) hyp.h_380 hyp.h_264)) >>
(tactic.intro_lst [`hyp.h_474] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) x) = (product (difference (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (difference b1 b)))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (product (product b2 (difference a1 (product (difference b1 b) c1))) (difference b1 b))) (product (product (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product (difference (quotient (difference (product (difference b1 b) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (product b2 (difference a1 (product (difference b1 b) c1)))) (difference b1 b))) hyp.h_473 hyp.h_474)))) >>
(((tactic.intro_lst [`hyp.h_475] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (quotient (difference (product (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product (product b2 (difference a1 x)) (product (product b2 (difference a1 x)) (difference b1 b)))) = (product (difference (quotient (difference (product (difference b1 b) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (product b2 (difference a1 x))) (difference b1 b)))) (product b c) (product (difference b1 b) c1) hyp.h_368 hyp.h_475)) >>
(tactic.intro_lst [`hyp.h_476] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product (quotient (difference (product (difference b1 b) (product b2 x)) (product b2 x)) (product b2 x)) (product b2 x)) (product (product b2 x) (product (product b2 x) (difference b1 b)))) = (product (difference (quotient (difference (product (difference b1 b) (product b2 x)) (product b2 x)) (product b2 x)) (product b2 x)) (difference b1 b)))) b (difference a1 (product b c)) hyp.h_290 hyp.h_476))) >>
((tactic.intro_lst [`hyp.h_477] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference x (product (product b2 b) (product (product b2 b) (difference b1 b)))) = (product (difference (quotient (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product b2 b)) (product b2 b)) (difference b1 b)))) (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product (quotient (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product b2 b)) (product b2 b)) hyp.h_470 hyp.h_477)) >>
(tactic.intro_lst [`hyp.h_478] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product (difference (quotient (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product b2 b)) (product b2 b)) (difference b1 b)))) (product b2 b) (difference (difference (product (difference b1 b) (product b2 b)) (product b2 b)) (product (product b2 b) (product (product b2 b) (difference b1 b)))) hyp.h_469 hyp.h_478) >>
tactic.intro_lst [`hyp.h_479]))))))) >>
(((((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b2 b) = (product (difference (quotient x (product b2 b)) (product b2 b)) (difference b1 b)))) (product b2 (product b2 b)) (difference (product (difference b1 b) (product b2 b)) (product b2 b)) hyp.h_444 hyp.h_479) >>
tactic.intro_lst [`hyp.h_480]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b2 b) = (product (difference x (product b2 b)) (difference b1 b)))) b2 (quotient (product b2 (product b2 b)) (product b2 b)) hyp.h_428 hyp.h_480) >>
tactic.intro_lst [`hyp.h_481])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b2 b) = (product x (difference b1 b)))) b (difference b2 (product b2 b)) hyp.h_396 hyp.h_481) >>
tactic.intro_lst [`hyp.h_482]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient b2 (difference b1 b)) (difference b1 b))) = (product (product (difference b1 b) (quotient b2 (difference b1 b))) x))) (difference b1 b) (product (difference b1 b) (difference b1 b)) hyp.h_99 hyp.h_175) >>
tactic.intro_lst [`hyp.h_483]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (difference b1 b) x) = (product (product (difference b1 b) (quotient b2 (difference b1 b))) (difference b1 b)))) b2 (product (quotient b2 (difference b1 b)) (difference b1 b)) hyp.h_64 hyp.h_483) >>
tactic.intro_lst [`hyp.h_484]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product (product (difference b1 b) (quotient b2 (difference b1 b))) (difference b1 b)))) (product b2 b) (product (difference b1 b) b2) hyp.h_400 hyp.h_484) >>
tactic.intro_lst [`hyp.h_485])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x (difference b1 b)) = (product (difference b1 b) (quotient b2 (difference b1 b))))) (product b2 b) (product (product (difference b1 b) (quotient b2 (difference b1 b))) (difference b1 b)) hyp.h_485 hyp.h_35) >>
tactic.intro_lst [`hyp.h_486]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient x (difference b1 b)) = (product (difference b1 b) (quotient b2 (difference b1 b))))) (product b (difference b1 b)) (product b2 b) hyp.h_482 hyp.h_486) >>
tactic.intro_lst [`hyp.h_487])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product (difference b1 b) (quotient b2 (difference b1 b))))) b (quotient (product b (difference b1 b)) (difference b1 b)) hyp.h_403 hyp.h_487) >>
tactic.intro_lst [`hyp.h_488]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (difference b1 b) (product (difference b1 b) (quotient x (difference b1 b)))) = (quotient x (difference b1 b)))) b2 (difference (difference b1 b) (product b2 b)) hyp.h_399 hyp.h_260) >>
tactic.intro_lst [`hyp.h_489])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((difference (difference b1 b) x) = (quotient b2 (difference b1 b)))) b (product (difference b1 b) (quotient b2 (difference b1 b))) hyp.h_488 hyp.h_489) >>
tactic.intro_lst [`hyp.h_490]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x (difference b1 b)) = b2)) (difference (difference b1 b) b) (quotient b2 (difference b1 b)) hyp.h_490 hyp.h_64) >>
tactic.intro_lst [`hyp.h_491]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient b1 b) b)) = (product (product b (quotient b1 b)) x))) b (product b b) hyp.h_101 hyp.h_126) >>
tactic.intro_lst [`hyp.h_492]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b x) = (product (product b (quotient b1 b)) b))) b1 (product (quotient b1 b) b) hyp.h_57 hyp.h_492) >>
tactic.intro_lst [`hyp.h_493])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product x b) (product b (product b (quotient b1 b)))) = b)) b1 (product (quotient b1 b) b) hyp.h_57 hyp.h_78) >>
tactic.intro_lst [`hyp.h_494]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product x b) (product (product x b) (product b (product b (quotient b1 b))))) = (product b (product b (quotient b1 b))))) b1 (product (quotient b1 b) b) hyp.h_57 hyp.h_254) >>
tactic.intro_lst [`hyp.h_495] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product b1 b) x) = (product b (product b (quotient b1 b))))) b (product (product b1 b) (product b (product b (quotient b1 b)))) hyp.h_494 hyp.h_495)))))) >>
(((((tactic.intro_lst [`hyp.h_496] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b) = (product b (quotient b1 b)))) (product b b1) (product (product b (quotient b1 b)) b) hyp.h_493 hyp.h_27)) >>
(tactic.intro_lst [`hyp.h_497] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b b) (product x b)) = (product (product b x) (product b b)))) (product b (quotient b1 b)) (quotient (product b b1) b) hyp.h_497 hyp.h_122))) >>
((tactic.intro_lst [`hyp.h_498] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b b) (product (product b (quotient b1 b)) b)) = (product x (product b b)))) (difference (product b1 b) b) (product b (product b (quotient b1 b))) hyp.h_496 hyp.h_498)) >>
(tactic.intro_lst [`hyp.h_499] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b b) x) = (product (difference (product b1 b) b) (product b b)))) (product b b1) (product (product b (quotient b1 b)) b) hyp.h_493 hyp.h_499)))) >>
(((tactic.intro_lst [`hyp.h_500] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product b b1)) = (product (difference (product b1 b) b) x))) b (product b b) hyp.h_101 hyp.h_500)) >>
(tactic.intro_lst [`hyp.h_501] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product b x) b) b) = (product b x))) (product b (quotient b1 b)) (quotient (product b b1) b) hyp.h_497 hyp.h_26))) >>
((tactic.intro_lst [`hyp.h_502] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient (product x b) b) = x)) (difference (product b1 b) b) (product b (product b (quotient b1 b))) hyp.h_496 hyp.h_502)) >>
(tactic.intro_lst [`hyp.h_503] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b) = (difference (product b1 b) b))) (product b (product b b1)) (product (difference (product b1 b) b) b) hyp.h_501 hyp.h_503))))) >>
((((tactic.intro_lst [`hyp.h_504] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (quotient (product b (product b b1)) b) x) = b)) (product b (product b b1)) (product (quotient (product b (product b b1)) b) b) hyp.h_54 hyp.h_250)) >>
(tactic.intro_lst [`hyp.h_505] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference x (product b (product b b1))) = b)) (difference (product b1 b) b) (quotient (product b (product b b1)) b) hyp.h_504 hyp.h_505))) >>
((tactic.intro_lst [`hyp.h_506] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient (quotient b1 b) b) b)) = (product (product b (quotient (quotient b1 b) b)) x))) b (product b b) hyp.h_101 hyp.h_120)) >>
(tactic.intro_lst [`hyp.h_507] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b x) = (product (product b (quotient (quotient b1 b) b)) b))) (quotient b1 b) (product (quotient (quotient b1 b) b) b) hyp.h_58 hyp.h_507)))) >>
(((tactic.intro_lst [`hyp.h_508] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product x b) (product b (product b (quotient (quotient b1 b) b)))) = b)) (quotient b1 b) (product (quotient (quotient b1 b) b) b) hyp.h_58 hyp.h_79)) >>
(tactic.intro_lst [`hyp.h_509] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product b (product b (quotient (quotient b1 b) b)))) = b)) b1 (product (quotient b1 b) b) hyp.h_57 hyp.h_509))) >>
((tactic.intro_lst [`hyp.h_510] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (product x b) (product (product x b) (product b (product b (quotient (quotient b1 b) b))))) = (product b (product b (quotient (quotient b1 b) b))))) (quotient b1 b) (product (quotient (quotient b1 b) b) b) hyp.h_58 hyp.h_255)) >>
(tactic.intro_lst [`hyp.h_511] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference x (product x (product b (product b (quotient (quotient b1 b) b))))) = (product b (product b (quotient (quotient b1 b) b))))) b1 (product (quotient b1 b) b) hyp.h_57 hyp.h_511) >>
tactic.intro_lst [`hyp.h_512])))))) >>
((((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference b1 x) = (product b (product b (quotient (quotient b1 b) b))))) b (product b1 (product b (product b (quotient (quotient b1 b) b)))) hyp.h_510 hyp.h_512) >>
tactic.intro_lst [`hyp.h_513]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b) = (product b (quotient (quotient b1 b) b)))) (product b (quotient b1 b)) (product (product b (quotient (quotient b1 b) b)) b) hyp.h_508 hyp.h_24) >>
tactic.intro_lst [`hyp.h_514])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (quotient (product b (quotient b1 b)) b) b)) = (product (product b (quotient (product b (quotient b1 b)) b)) x))) b (product b b) hyp.h_101 hyp.h_134) >>
tactic.intro_lst [`hyp.h_515]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product b (product x b)) = (product (product b x) b))) (product b (quotient (quotient b1 b) b)) (quotient (product b (quotient b1 b)) b) hyp.h_514 hyp.h_515) >>
tactic.intro_lst [`hyp.h_516]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b (product (product b (quotient (quotient b1 b) b)) b)) = (product x b))) (difference b1 b) (product b (product b (quotient (quotient b1 b) b))) hyp.h_513 hyp.h_516) >>
tactic.intro_lst [`hyp.h_517]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product b x) = (product (difference b1 b) b))) (product b (quotient b1 b)) (product (product b (quotient (quotient b1 b) b)) b) hyp.h_508 hyp.h_517) >>
tactic.intro_lst [`hyp.h_518])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, (x = (product (difference b1 b) b))) (difference (product b1 b) b) (product b (product b (quotient b1 b))) hyp.h_496 hyp.h_518) >>
tactic.intro_lst [`hyp.h_519]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((quotient (product (product b x) b) b) = (product b x))) (product b (quotient (quotient b1 b) b)) (quotient (product b (quotient b1 b)) b) hyp.h_514 hyp.h_22) >>
tactic.intro_lst [`hyp.h_520])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient (product x b) b) = x)) (difference b1 b) (product b (product b (quotient (quotient b1 b) b))) hyp.h_513 hyp.h_520) >>
tactic.intro_lst [`hyp.h_521]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b) = (difference b1 b))) (difference (product b1 b) b) (product (difference b1 b) b) hyp.h_519 hyp.h_521) >>
tactic.intro_lst [`hyp.h_522])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (difference x b)) = b)) (difference b1 b) (quotient (difference (product b1 b) b) b) hyp.h_522 hyp.h_224) >>
tactic.intro_lst [`hyp.h_523]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product x b) (product (difference x b) b1)) = (product (product x (difference x b)) (product b b1)))) (difference b1 b) (quotient (difference (product b1 b) b) b) hyp.h_522 hyp.h_159) >>
tactic.intro_lst [`hyp.h_524]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x (product (difference (difference b1 b) b) b1)) = (product (product (difference b1 b) (difference (difference b1 b) b)) (product b b1)))) (difference (product b1 b) b) (product (difference b1 b) b) hyp.h_519 hyp.h_524) >>
tactic.intro_lst [`hyp.h_525]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (difference (product b1 b) b) (product (difference (difference b1 b) b) b1)) = (product x (product b b1)))) b (product (difference b1 b) (difference (difference b1 b) b)) hyp.h_523 hyp.h_525) >>
tactic.intro_lst [`hyp.h_526])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference x (product x (product (difference (quotient (difference (product b1 b) b) b) b) b1))) = (product (difference (quotient (difference (product b1 b) b) b) b) b1))) (difference (product b1 b) b) (product (quotient (difference (product b1 b) b) b) b) hyp.h_60 hyp.h_251) >>
tactic.intro_lst [`hyp.h_527]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (difference (product b1 b) b) (product (difference (product b1 b) b) (product (difference x b) b1))) = (product (difference x b) b1))) (difference b1 b) (quotient (difference (product b1 b) b) b) hyp.h_522 hyp.h_527) >>
tactic.intro_lst [`hyp.h_528] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((difference (difference (product b1 b) b) x) = (product (difference (difference b1 b) b) b1))) (product b (product b b1)) (product (difference (product b1 b) b) (product (difference (difference b1 b) b) b1)) hyp.h_526 hyp.h_528)))))) >>
(((((tactic.intro_lst [`hyp.h_529] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, (x = (product (difference (difference b1 b) b) b1))) b (difference (difference (product b1 b) b) (product b (product b b1))) hyp.h_506 hyp.h_529)) >>
(tactic.intro_lst [`hyp.h_530] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((quotient x b1) = (difference (difference b1 b) b))) b (product (difference (difference b1 b) b) b1) hyp.h_530 hyp.h_33))) >>
((tactic.intro_lst [`hyp.h_531] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product x x) (product (product (quotient b b1) (difference b1 b)) b2)) = (product (product x (product (quotient b b1) (difference b1 b))) (product x b2)))) b1 (product b1 b1) hyp.h_100 hyp.h_207)) >>
(tactic.intro_lst [`hyp.h_532] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x (product (product (quotient b b1) (difference b1 b)) b2)) = (product (product b1 (product (quotient b b1) (difference b1 b))) (product b1 b2)))) b1 (product b1 b1) hyp.h_100 hyp.h_532)))) >>
(((tactic.intro_lst [`hyp.h_533] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 (quotient b b1)) x) = (product (product b1 b1) (product (quotient b b1) (difference b1 b))))) b (product b1 (difference b1 b)) hyp.h_223 hyp.h_179)) >>
(tactic.intro_lst [`hyp.h_534] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 (quotient b b1)) b) = (product x (product (quotient b b1) (difference b1 b))))) b1 (product b1 b1) hyp.h_100 hyp.h_534))) >>
((tactic.intro_lst [`hyp.h_535] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 b1) x) = (product (product b1 (quotient b b1)) (product b1 b1)))) b (product (quotient b b1) b1) hyp.h_63 hyp.h_151)) >>
(tactic.intro_lst [`hyp.h_536] >>
tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product x b) = (product (product b1 (quotient b b1)) x))) b1 (product b1 b1) hyp.h_100 hyp.h_536) >>
tactic.intro_lst [`hyp.h_537])))) >>
((((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product (product b1 (quotient b b1)) x) (product b b2)) = (product (product (product b1 (quotient b b1)) b) (product x b2)))) b1 (product b1 b1) hyp.h_100 hyp.h_209) >>
tactic.intro_lst [`hyp.h_538]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product x (product b b2)) = (product (product (product b1 (quotient b b1)) b) (product b1 b2)))) (product b1 b) (product (product b1 (quotient b b1)) b1) hyp.h_537 hyp.h_538) >>
tactic.intro_lst [`hyp.h_539])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 b) (product b b2)) = (product x (product b1 b2)))) (product b1 (product (quotient b b1) (difference b1 b))) (product (product b1 (quotient b b1)) b) hyp.h_535 hyp.h_539) >>
tactic.intro_lst [`hyp.h_540]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule1 (λ x : i, ((product (product b1 b) (product b b2)) = x)) (product b1 (product (product (quotient b b1) (difference b1 b)) b2)) (product (product b1 (product (quotient b b1) (difference b1 b))) (product b1 b2)) hyp.h_533 hyp.h_540) >>
tactic.intro_lst [`hyp.h_541]))) >>
(((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 b) (product b b2)) = (product b1 (product (product x (difference b1 b)) b2)))) (difference (difference b1 b) b) (quotient b b1) hyp.h_531 hyp.h_541) >>
tactic.intro_lst [`hyp.h_542]) >>
(tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 b) (product b b2)) = (product b1 (product x b2)))) b2 (product (difference (difference b1 b) b) (difference b1 b)) hyp.h_491 hyp.h_542) >>
tactic.intro_lst [`hyp.h_543])) >>
((tactic.interactive.apply ```(gapt.lk.EqualityLeftRule2 (λ x : i, ((product (product b1 b) (product b b2)) = (product b1 x))) b2 (product b2 b2) hyp.h_94 hyp.h_543) >>
tactic.intro_lst [`hyp.h_544]) >>
(tactic.interactive.apply ```(gapt.lk.LogicalAxiom hyp.h_544 hyp.h_281) >>
tactic.intro_lst [`hyp.h_281] >>
tactic.interactive.apply ```(gapt.lk.LogicalAxiom hyp.h_281 hyp.h_14))))))))))

end gapt_export
