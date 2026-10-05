// § evalFuncPkgParamVarSelKeepsCall237
// power operator in the body
package q;
  function automatic int unsigned fwidth(int unsigned i);
    return unsigned'(2 ** (i - 1) - 1);
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fwidth(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(4)) u (.o(o));
endmodule
