// § evalFuncPkgParamVarSelKeepsCall237
// a local variable copies the parameter, then the local is selected (no select of the parameter)
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned i);
    automatic logic [2:0][7:0] t = ENC;
    return t[i];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
