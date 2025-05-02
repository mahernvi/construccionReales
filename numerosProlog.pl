%naturales

nat(0).
nat(s(X)):-nat(X).

p2d(0,0).
p2d(s(N),R2) :- p2d(N,R), R2 is R+1.

suma(0,N2, N2).
suma(s(N1),N2,s(R)):- suma(N1,N2,R).

mult(_, 0, 0).
mult(N1, s(N2),R2):- mult(N1,N2,R), suma(N1,R,R2).

%enteros

int((N1,N2)):- nat(N1),nat(N2).

pz2dz((0,0),0).
pz2dz((N1,N2),R):-p2d(N1,D1),p2d(N2,D2),R is D1-D2.

sumaZP((0,0),(N1,N2),(N1,N2)).
sumaZP((N1,N2),(M1,M2),(R1,R2)) :- suma(N1,M1,R1),suma(N2,M2,R2).

multZP((_,_),(0,0),(0,0)).
multZP((N1,N2),(M1,M2),(R1,R2)):-
mult(N1,M1,RA1),mult(N2,M2,RA2),suma(RA1,RA2,R1),mult(N1,M2,RB1),mult(N2,M1,RB2),suma(RB1,RB2,R2).

eqZP(Z1,Z2) :-
    pz2dz(Z1,V1),
    pz2dz(Z2,V2),
    V1 =:= V2.

negZP((A,B),(B,A)).

%racionales

rat((Num,Den)) :-
    int(Num),                     
    int(Den),                     
    \+ eqZP(Den,(0,0)).

qr2float((N,D),F) :-
    pz2dz(N,Num),
    pz2dz(D,Den),
    F is Num / Den. 

sumaQP((N1,D1),(N2,D2),(N3,D3)) :-
    multZP(N1,D2,T1),            
    multZP(N2,D1,T2),            
    sumaZP(T1,T2,N3),            
    multZP(D1,D2,D3).            


multQP((N1,D1),(N2,D2),(N3,D3)) :-
    multZP(N1,N2,N3),            
    multZP(D1,D2,D3).            


negQP((N,D),(Nneg,D)) :-
    negZP(N,Nneg).


invQP((N,D),(D,N)) :- \+ eqZP(N,(0,0)).


restaQP(Q1,Q2,Q3) :-
    negQP(Q2,Q2N),
    sumaQP(Q1,Q2N,Q3).


divQP(Q1,Q2,Q3) :-
    invQP(Q2,Q2I),
    multQP(Q1,Q2I,Q3).


eqQP((N1,D1),(N2,D2)) :-
    multZP(N1,D2,P1),
    multZP(N2,D1,P2),
    eqZP(P1,P2).   


lessQP(Q1,Q2):-
    qr2float(Q1,F1),
    qr2float(Q2,F2),
    F1 < F2.


leQP(Q1,Q2):-
    qr2float(Q1,F1),
    qr2float(Q2,F2),
    F1 =< F2.

%reales

real(real(L,U)):-
    rat(L), rat(U),                   % son racionales bien formados
    lessQP(L,U).    

% rat2real(+Q, -R)  –  inyección ℚ ↦ ℝ (corte trivial)
% Corte α_Q = {q ∈ ℚ : q < Q}
rat2real(Q, real(P,Q)):-
    % elegimos un testigo P < Q; por simplicidad, el propio Q menos 1
    rat(One), qr2float(One,1.0),  % One = 1/1 ya está en racionales.pl
    sumaQP(Q,negQP(One,_),P0),    % P0 = Q‑1
    ( lessQP(P0,Q) -> P=P0 ; P=Q ),   % garantizamos P<Q (si Q<1 vale usar Q‑1)
    real(real(P,Q)).

% real2float(+R, -F)  –  Valor numérico aproximado usando borde superior
real2float(real(_,U), F):- qr2float(U,F).

sumaRP(real(L1,U1), real(L2,U2), real(L,U)):-
    sumaQP(L1,L2,L),
    sumaQP(U1,U2,U).


negRP(real(L,U), real(LN,UN)):-
    negQP(U,LN),    % LN = -U  pertenece al corte negado
    negQP(L,UN).    % UN = -L  es su supremo


restaRP(R1,R2,R):- negRP(R2,Neg), sumaRP(R1,Neg,R).


multRP(real(L1,U1), real(L2,U2), real(L,U)):-
    % aseguramos positividad mínima con L>=0 (idealmente >0)
    leQP(rat((0,0)),L1), leQP(rat((0,0)),L2),
    multQP(L1,L2,L),
    multQP(U1,U2,U).


invRP(real(L,U), real(LI,UI)):-
    % asumimos R>0  ⇒  L>0  ⇒  Den≠0
    lessQP(rat((0,0)),L),
    invQP(U,LI),    % LI = 1/U  es un elemento del corte (<= verdadero inverso)
    invQP(L,UI).    % UI = 1/L  es la cota superior

divRP(R1,R2,R):- invRP(R2,Inv),multRP(R1,Inv,R).


eqRP(real(_,U1), real(_,U2)):- eqQP(U1,U2).


lessRP(real(_,U1), real(P2,_)):- lessQP(U1,P2).


leRP(R1,R2):- lessRP(R1,R2) ; eqRP(R1,R2).

%Parte final
'+'(F1,F2,F):-
    real2float(R1,F1),real2float(R2,F2),sumaRP(R1,R2,R),real2float(R,F).

'-'(F1,F2,F):-
    real2float(R1,F1),real2float(R2,F2),restaRP(R1,R2,R),real2float(R,F).

'·'(F1,F2,F):-
    real2float(R1,F1),real2float(R2,F2),multRP(R1,R2,R),real2float(R,F).

'/'(F1,F2,F):-
    real2float(R1,F1),real2float(R2,F2),divRP(R1,R2,R),real2float(R,F).
