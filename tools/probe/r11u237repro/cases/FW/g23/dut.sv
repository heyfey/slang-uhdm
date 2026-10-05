// § evalFuncPkgParamVarSelKeepsCall237
// a module-local function selects a package parameter by its formal
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  function automatic int unsigned fw(int unsigned i);
    return q::ENC[i];
  endfunction
  assign o = fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
