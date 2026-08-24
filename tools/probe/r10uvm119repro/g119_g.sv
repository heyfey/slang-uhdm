// arm G — MULTIPLE INSTANCES and receiver-name variety (an arm that names
// everything the same is self-confirming): 1, 2 and 3 randomize sites per
// scope, different receiver spellings, orders, cases and lengths.
class p_g;
  rand int unsigned v_g;
endclass

class one_g;
  p_g zzz;
  int unsigned n1;
  task t1();
    if (!zzz.randomize() with { v_g > 1; }) n1 = 1;
  endtask
endclass

class two_g;
  p_g Bee;
  p_g a;
  int unsigned n2;
  task t2();
    if (!a.randomize() with { v_g > 2; }) n2 = 1;
    if (!Bee.randomize() with { v_g > 3; }) n2 = 2;
  endtask
endclass

class three_g;
  p_g m_long_receiver_name_9;
  p_g X;
  p_g q7;
  int unsigned n3;
  task t3();
    if (!q7.randomize() with { v_g > 4; }) n3 = 1;
    if (!m_long_receiver_name_9.randomize() with { v_g > 5; }) n3 = 2;
    if (!X.randomize() with { v_g > 6; }) n3 = 3;
  endtask
endclass

module top_g;
  one_g o1; two_g o2; three_g o3;
  initial begin
    o1 = new(); o2 = new(); o3 = new();
    o1.t1(); o2.t2(); o3.t3();
  end
endmodule
