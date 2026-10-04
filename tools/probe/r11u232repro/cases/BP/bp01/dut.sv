// r11u232 decode (no law written): BlackBePipeInt 15272, a defaulted override member read through a ternary; golden folds this small shape, the corpus row shares the operand object
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
  localparam cfg_s uni_p = dflt_p;
  localparam cfg_s ovr_p = '{a: 5, default: "inv"};
  localparam cfg_s mp_p = '{
    a: (ovr_p.a == "inv") ? uni_p.a : ovr_p.a,
    b: (ovr_p.b == "inv") ? uni_p.b : ovr_p.b,
    c: (ovr_p.c == "inv") ? uni_p.c : ovr_p.c
  };
endpackage
module top(output int o);

  assign o = pk::mp_p.b;
endmodule
