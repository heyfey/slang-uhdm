// § evalFuncPkgParamVarSelKeepsCall237
// the select behind a short-circuit && whose left side is false
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned i);
    return (i > 5) && (ENC[i] != 0);
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(1)) u (.o(o));
endmodule
