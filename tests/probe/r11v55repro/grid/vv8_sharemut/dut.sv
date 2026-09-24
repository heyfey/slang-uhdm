// r11v55 VERIFIER arm — "CLONE, NEVER SHARE" AT THE MUTATION SITE.  The law
// takes the object `emitExpr` returns and MUTATES its VpiSize / VpiValue /
// VpiDecompile in place.  If any two cont_assigns of the design can reach the
// SAME emitted object — the same pattern element read from two INSTANCES of
// one definition, or from two modules that share the package localparam — the
// second mutation silently rewrites the first.  Three instances read the same
// package literal through three different Lhs widths, and a second definition
// reads it again, so a shared object would show as a size that is wrong in
// every cell but the last.
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t LIT = '{n: 300, h: 16'hBEEF};
endpackage
module leaf8  #(parameter p::cfg_t C = p::LIT)(output logic [7:0]  o_n, output logic [7:0]  o_h);
  assign o_n = C.n;  assign o_h = C.h;
endmodule
module leaf32 #(parameter p::cfg_t C = p::LIT)(output logic [31:0] o_n, output logic [31:0] o_h);
  assign o_n = C.n;  assign o_h = C.h;
endmodule
module leaf64 #(parameter p::cfg_t C = p::LIT)(output logic [63:0] o_n, output logic [63:0] o_h);
  assign o_n = C.n;  assign o_h = C.h;
endmodule
module dut (output logic [7:0]  a_n, output logic [7:0]  a_h,
            output logic [31:0] b_n, output logic [31:0] b_h,
            output logic [63:0] c_n, output logic [63:0] c_h,
            output logic [7:0]  d_n, output logic [7:0]  d_h);
  leaf8  u_a (.o_n(a_n), .o_h(a_h));
  leaf32 u_b (.o_n(b_n), .o_h(b_h));
  leaf64 u_c (.o_n(c_n), .o_h(c_h));
  leaf8  u_d (.o_n(d_n), .o_h(d_h));   // a SECOND instance of leaf8
endmodule
