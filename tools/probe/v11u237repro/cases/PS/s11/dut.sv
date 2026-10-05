// § evalFuncPkgParamVarSelKeepsCall237
// unpacked array of structs, member of the selected element
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t ENC [3] = '{'{4, 3}, '{3, 2}, '{2, 1}};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i].m;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
