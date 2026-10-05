// § evalFuncPkgParamVarSelKeepsCall237
// selector a package localparam
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  localparam int K = 1;
  function automatic int unsigned fw(int unsigned i);
    return ENC[K] + i;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
