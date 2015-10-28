append([],L,L).
append([H|T],L,[H|R]) :-
    append(T,L,R).
