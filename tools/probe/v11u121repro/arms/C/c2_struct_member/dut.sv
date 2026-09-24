package vp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  logic en;
  logic [7:0] data;
  s_t st;
  logic [7:0] arr [4];
endpackage
module top (output logic [3:0] o, output logic [3:0] p);
  assign o = vp::st.a;
  assign p = vp::st.b[3:0];
endmodule
