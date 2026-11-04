package vp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  logic en;
  logic [7:0] data;
  s_t st;
  logic [7:0] arr [4];
endpackage
module top (output logic [7:0] o, output logic [7:0] q, output logic [7:0] r);
  assign o = vp ::data;
  assign q = vp:: data;
  assign r = vp
    ::data;
endmodule
