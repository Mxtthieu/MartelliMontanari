- op(20,xfy,?=).
set_echo :- assert(echo_on).
clr_echo :- retractall(echo_on).
echo(T) :- echo_on, !,write(T).
echo(_).
%unifie([f(X,Y) ?= f(g(Z),h(a)),Z ?= f(Y)]),!.
regle(X ?= T,rename) :- var(X),var(T),!.
regle(X ?= T,simplify) :- var(X),atomic(T),!.
regle(X ?= T, expand) :- var(X),compound(T), \+ occur_check(X,T),!.
regle(X ?= T,check) :- X \== T,occur_check(X,T),!.
regle(T ?= X,orient) :- var(X),nonvar(T),!.
regle(X ?= T,decompose) :-
compound(X),compound(T),functor(X,Name,Arity),functor(T,Name,Arity),!.
regle(X ?= T,clash) :- compound(X),compound(T),\+regle(X ?= T,decompose),!.
occur_check(V, T) :- var(V), V == T.
occur_check(V,T) :- var(V), nonvar(T), compound(T),arg(I,T,Value),occur_check(V,Value).
%reduit(R,E,P,Q) :- .
reduit(check,_,_,_) :- fail.
reduit(clash,_,_,_) :- fail.
reduit(rename,V ?= T ,[V ?= T | P] ,P) :- V = T.
reduit(simplify,V ?= T ,[V ?= T | P] ,P) :- V = T.
reduit(expand,V ?= T ,[V ?= T | P] ,P) :- V = T.
reduit(orient,T ?= V,[T?=V | P],[V?=T | P]).
reduit(decompose,V ?= T,[X?=Y |P],Q) :-
functor(X, Name, Arity),
functor(Y, Name, Arity),
functor(V, Name, Arity),
functor(T, Name, Arity),
decompose(X ?= Y, Z, Arity),
append(Z, P, Q).
decompose(_, [], 0).
decompose(X ?= Y, [Z ?= Q | R], Arity) :-
arg(Arity, X, Z),
arg(Arity, Y, Q),
succ(A, Arity),
decompose(X ?= Y, R, A).
unifie([]).
unifie([E | P]) :-
regle(E, R),
echo("system: "),
echo([E | P]),
echo("\n"),
echo(R),
echo(": "),
echo(E),
echo("\n"),
reduit(R, E, [E | P], Q),
unifie(Q),!.
unifie([], _).
unifie(X, C) :-
strategie(X, P, E, R, C),
echo("systeme: "),
echo([E | P]),
echo("\n"),
echo(R),
echo(": "),
echo(E),
echo("\n"),
reduit(R, E, [E | P], Q),
unifie(Q, C).
strategie(P, Q, E, R, choix_premier) :-
choix_premier(P, Q, E, R).
strategie(P, Q, E, R, choix_pondere) :-
choix_pondere(P, Q, E, R).
choix_premier([X | P], P, X, R) :-
regle(X, R).
choix_pondere([X], [], X, R) :-
regle(X, R).
choix_pondere([X | P], [Y | Q], X, RX) :-
choix_pondere(P, Q, Y, RY),
regle(X, RX),
weight(RX, PX),
weight(RY, PY),
PX >= PY.
choix_pondere([X | P], [X | Q], Y, RY) :-
choix_pondere(P, Q, Y, RY),
regle(X, RX),
weight(RX, PX),
weight(RY, PY),
PX =< PY.
weight(expand, 1).
weight(decompose, 2).
weight(orient, 3).
weight(simplify, 4).
weight(rename, 5).
weight(check, 6).
weight(clash, 7).
unif(P, S) :-
clr_echo,
( unifie(P, S) ->
write("\nYes\n\n") ;
write("\nNo\n\n"), fail ).
trace_unif(P, S) :-
set_echo,
( unifie(P, S) ->
write("\nYes\n\n") ;
write("\nNo\n\n"), fail ).