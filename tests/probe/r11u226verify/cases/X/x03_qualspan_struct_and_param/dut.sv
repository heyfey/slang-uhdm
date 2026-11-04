// § modStructMemberQualSpan214 § pkgQualOperandSpanInParam218 — one package's names as a module struct member bound and as operands of the module's parameter initializer
package cfg;
  localparam int W = 4;
  localparam int K = 3;
endpackage
module m #(parameter int P = cfg::W * cfg::K + 1)(output logic [31:0] o);
  typedef struct packed {
    logic [cfg::W-1:0] a;
    logic [cfg::K:0]   b;
  } s_t;
  s_t r;
  assign r = '1;
  assign o = 32'(r) + P;
endmodule
module top(output logic [31:0] o);
  m u(.o(o));
endmodule
