// § evalFuncPkgParamVarSelKeepsCall237
// wildcard import, unqualified call, a select by an expression index
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i - 1];
  endfunction
endpackage
module sub import q::*; #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
