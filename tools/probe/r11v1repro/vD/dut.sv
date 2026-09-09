package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
endpackage

interface fif #(parameter int W = 8) (input logic clk);
  import pk::*;
  localparam int HW = W/2;
  logic [W-1:0] d;
  wire  [W-1:0] q;
  st_t  s;
  assign q = d;
  function automatic int f(input int x); return x + W; endfunction
  task automatic t(); endtask
  modport mp (input d, output q, import f);
  modport slv (output d, input q);
endinterface

module use_mp  (fif.mp  p, output logic o); assign o = p.q[0]; endmodule
module use_pl  (fif     p, output logic o); assign o = p.q[0]; endmodule

module top (input logic clk, output logic [1:0] o);
  fif #(.W(16)) u (.clk(clk));
  use_mp a0 (.p(u.mp), .o(o[0]));
  use_pl a1 (.p(u),    .o(o[1]));
endmodule
