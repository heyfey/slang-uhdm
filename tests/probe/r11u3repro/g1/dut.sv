// r11u3 grid g1 — the struct-parameter MEMBER SELECT as an instance parameter
// override actual, re-passed one level, and read by a cont_assign.
package p;
  typedef enum logic [1:0] { A = 2'b01 } e_t;
  typedef struct packed { e_t f; logic [3:0] g; } s_t;
endpackage

module leaf(output logic [1:0] o);
  parameter p::e_t P = 0;
  assign o = P;
endmodule

module mid(output logic [1:0] o);
  parameter p::e_t P = 0;
  leaf #(.P(P)) u_leaf(.o(o));
endmodule

module lg(output logic [3:0] o);
  parameter int G = 0;
  assign o = G[3:0];
endmodule

module top(output logic [1:0] o, output logic [3:0] o2);
  import p::*;
  parameter s_t C = 6'b01_1010;
  mid #(.P(C.f)) u_mid(.o(o));
  lg  #(.G(C.g)) u_lg2(.o(o2));
endmodule
