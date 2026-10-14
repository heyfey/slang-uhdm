// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  typedef struct packed { logic [1:0] f; } st_t;
  st_t st;
  assign st = s;
  child c (.d(m[st.f[0]][1]), .q(o));
endmodule
