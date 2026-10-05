// § evalFuncPkgParamVarSelKeepsCall237
// part select by a formal on a package vector parameter
package q;
  localparam logic [31:0] W = 32'hA5A5_5A5A;
  function automatic int unsigned fw(int unsigned i);
    return W[i +: 4];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
