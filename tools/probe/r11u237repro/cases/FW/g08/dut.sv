// § evalFuncPkgParamVarSelKeepsCall237
// branch not taken guards the member read
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] ENC = '{'{4, 3}, '{3, 2}, '{2, 1}};
  function automatic int unsigned fw(int unsigned i);
    if (i > 100) return ENC[i].e;
    return 5;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
