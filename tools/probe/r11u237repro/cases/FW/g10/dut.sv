// § evalFuncPkgParamVarSelKeepsCall237
// module-local function, module localparam struct array
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  localparam q::enc_t [0:2] ENC = '{'{4, 3}, '{3, 2}, '{2, 1}};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i].e;
  endfunction
  assign o = fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
