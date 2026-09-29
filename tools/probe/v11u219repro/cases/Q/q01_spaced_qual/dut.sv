// § modStructMemberQualSpan214 — a spaced qualifier `cfg :: W` and a parenthesized `(cfg::W)` in a module struct member range
package cfg;
  parameter int W = 8;
  parameter int K = 3;
endpackage
module top(output logic [15:0] o);
  typedef struct packed {
    logic [cfg :: W-1:0] a;
    logic [(cfg::K)-1:0] b;
    logic [cfg::K*2:0] c;
  } s_t;
  s_t s;
  assign s = '0;
  assign o = s[15:0];
endmodule
