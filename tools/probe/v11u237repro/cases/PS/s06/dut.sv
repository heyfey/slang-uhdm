// § evalFuncPkgParamVarSelKeepsCall237
// a function of package r selects package q's parameter by its formal
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
endpackage
package r;
  function automatic int unsigned fw(int unsigned i);
    return q::ENC[i];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = r::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(1)) u (.o(o));
endmodule
