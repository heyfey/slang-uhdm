// § evalFuncPkgParamVarSelKeepsCall237
// literal actual, no parameter
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] ENC = '{'{4, 3}, '{3, 2}, '{2, 1}};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i].e;
  endfunction
endpackage
module sub (output logic [31:0] o);
  assign o = q::fw(2);
endmodule
module top (output logic [31:0] o);
  sub u (.o(o));
endmodule
