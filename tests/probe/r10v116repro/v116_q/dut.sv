// v116 arm Q -- the EMPTY with block, and member-form randomize(null),
// plus rand_mode / constraint_mode calls sitting right beside them.
class cfg_q;
  rand int w_one;
  rand int w_two;
  int lid_q;
  constraint c_q { w_one < 100; }
  function void sweep();
    if (!randomize(w_one) with { })
      lid_q = 1;
    if (!randomize() with { })
      lid_q = 2;
    if (!randomize(null))
      lid_q = 3;
    w_one.rand_mode(0);
    c_q.constraint_mode(0);
    if (!randomize(w_two) with { w_two > 0; })
      lid_q = 4;
  endfunction
endclass
module top_q;
  cfg_q q_one;
  int r_q;
  initial begin
    q_one = new();
    q_one.sweep();
    if (!q_one.randomize(null))
      r_q = 9;
  end
endmodule
