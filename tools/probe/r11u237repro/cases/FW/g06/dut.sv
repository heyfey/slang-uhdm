// § evalFuncPkgParamVarSelKeepsCall237
// the member read inside a nested callee called from a loop
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] ENC = '{'{4, 3}, '{3, 2}, '{2, 1}};
  function automatic int unsigned in(int unsigned i);
    return ENC[i].e;
  endfunction
  function automatic int unsigned fw(int unsigned n);
    automatic int unsigned r = 0;
    for (int unsigned i = 0; i < n; i++) r = r + in(i);
    return r;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
