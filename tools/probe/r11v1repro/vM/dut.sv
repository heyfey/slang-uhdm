interface vif #(parameter type T = logic [7:0], parameter int W = 4);
  T v;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

interface aif #(parameter int N = 2);
  logic [N-1:0] a;
  modport mp (input a);
endinterface

module use_v (vif.mp p, output logic o); assign o = p.d[0]; endmodule
module use_a (aif    p, output logic o); assign o = p.a[0]; endmodule

module top (output logic [3:0] o);
  vif #(.T(logic [15:0]), .W(9)) uv ();
  aif #(.N(5)) ua ();
  aif          uaa [2][3] ();
  use_v v0 (.p(uv.mp), .o(o[0]));
  use_a a0 (.p(ua),    .o(o[1]));
  assign o[2] = uaa[0][0].a[0];
  assign o[3] = 1'b0;
endmodule
