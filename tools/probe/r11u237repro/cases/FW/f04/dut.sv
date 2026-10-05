// § evalFuncPkgParamVarSelKeepsCall237
// element+member select on a package struct-array parameter
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] ENC = '{'{4, 3}, '{3, 2}, '{2, 1}};
  function automatic int unsigned fwidth(int unsigned i);
    return ENC[i].e + ENC[i].m;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fwidth(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
