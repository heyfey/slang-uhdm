// r10uvm131 arm A — join kinds x named/unnamed x label position, module initial.
// Names/order/case deliberately varied so an agreeing cell is not self-confirming.
module ArmAKinds;
  int q7, Zed, n_3;
  initial begin
    // unnamed, all three joins, in a scrambled order
    fork
      q7 = 1;
    join_any
    fork
      Zed = 2;
    join_none
    fork
      n_3 = 3;
    join
    // named INSIDE the fork keyword (fork : lbl), all three joins
    fork : Wagon
      q7 = 4;
    join_none
    fork : bravo9
      Zed = 5;
    join
    fork : c_Tail
      n_3 = 6;
    join_any
    // named BEFORE the fork keyword (lbl : fork)
    outer_A : fork
      q7 = 7;
    join_any
    OUTER_b : fork
      Zed = 8;
    join_none
    outer3 : fork
      n_3 = 9;
    join
    // named INSIDE with an END LABEL on the join keyword
    fork : dEndy
      q7 = 10;
    join_none : dEndy
    fork : e2
      Zed = 11;
    join : e2
    // multi-arm forks (more than one parallel statement)
    fork : multi_K
      q7 = 12;
      Zed = 13;
      n_3 = 14;
    join_any
    fork
      q7 = 15;
      Zed = 16;
    join_none
  end
endmodule
