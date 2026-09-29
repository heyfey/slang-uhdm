// § modStructMemberQualSpan214 — the qualified bound written by a macro (whole name in the body, and the package name as an actual)
`define WW cfg::W
`define QN(P) P::N
package cfg;
  parameter int W = 8;
  parameter int N = 4;
endpackage
module top(output logic [11:0] o);
  typedef struct packed {
    logic [`WW-1:0] a;
    logic [`QN(cfg)-1:0] b;
  } s_t;
  s_t s;
  assign s = '0;
  assign o = s;
endmodule
