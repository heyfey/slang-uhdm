// v119 arm J — a PARAMETERISED class receiver, a STATIC class property
// receiver, a virtual-class handle and a typedef'd handle.
class box_j #(int unsigned W_J = 8);
  rand int unsigned j_v;
  rand int unsigned j_w;
endclass

virtual class abs_j;
  pure virtual function int unsigned kind_j();
endclass

class real_j extends abs_j;
  rand int unsigned j_r;
  virtual function int unsigned kind_j();
    return 1;
  endfunction
endclass

class hold_j;
  static box_j #(8) s_j;
  typedef box_j #(16) wide_j_t;
  wide_j_t w_j;
  real_j r_j;
  abs_j a_j;
  int unsigned out_j;
  task run_j();
    // a PARAMETERISED receiver reached through a STATIC property
    if (!hold_j::s_j.randomize() with { j_v > 1; }) out_j = 1;
    // a TYPEDEF'd parameterised handle
    if (!w_j.randomize() with { j_w > 2; }) out_j = 2;
    // a DERIVED handle held in the derived type
    if (!r_j.randomize() with { j_r > 3; }) out_j = 3;
    // the same static property WITHOUT the class scope
    if (!s_j.randomize() with { j_v > 4; }) out_j = 4;
  endtask
endclass

module top_j;
  hold_j h_j;
  initial begin
    h_j = new();
    h_j.run_j();
  end
endmodule
