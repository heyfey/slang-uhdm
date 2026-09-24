package vp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  logic en;
  logic [7:0] data;
  s_t st;
  logic [7:0] arr [4];
endpackage
module top (input logic s, output logic [3:0] o, output logic e);
  assign o = s ? vp :: st.a : vp :: arr[1][3:0];
  assign e = vp  ::  en;
endmodule
