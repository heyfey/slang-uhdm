package vp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  logic en;
  logic [7:0] data;
  s_t st;
  logic [7:0] arr [4];
endpackage
module sub (input logic [7:0] i, output logic [7:0] o); assign o = i + 8'd1; endmodule
module top (output logic [7:0] o, output logic [15:0] c);
  sub u (.i(vp::data), .o(o));
  assign c = {vp::data, vp::arr[2]};
endmodule
