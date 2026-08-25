// v131 arm A — the full fork face matrix in a module initial.
module Falpha;
  int Q7, wq, zeta;
  initial begin
    // unnamed, single-statement bodies, all three joins
    fork Q7 = 3; join
    fork wq = 4; join_any
    fork zeta = 5; join_none
    // unnamed, begin bodies
    fork begin Q7 = 6; wq = 7; end join
    fork begin wq = 8; end join_any
    fork begin zeta = 9; end join_none
    // unnamed, two parallel begins
    fork begin Q7 = 10; end begin wq = 11; end join
    fork begin Q7 = 12; end begin wq = 13; end join_any
    fork begin zeta = 14; end begin Q7 = 15; end join_none
    // named via fork : lbl
    fork : Kb1 Q7 = 16; join
    fork : kB2 wq = 17; join_any
    fork : KB_3 zeta = 18; join_none
    // named via fork : lbl with end labels
    fork : mixCase Q7 = 19; join : mixCase
    fork : n0Ne wq = 20; join_any : n0Ne
    fork : Zz9 zeta = 21; join_none : Zz9
    // outer-label form  lbl : fork
    Outer1 : fork Q7 = 22; join
    outer_2 : fork wq = 23; join_any
    OUTER3 : fork zeta = 24; join_none
    // outer-label form with end labels
    tail1 : fork Q7 = 25; join : tail1
    TaIl2 : fork wq = 26; join_any : TaIl2
    t_a_i_l_3 : fork zeta = 27; join_none : t_a_i_l_3
  end
endmodule
