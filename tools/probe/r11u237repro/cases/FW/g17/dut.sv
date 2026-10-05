// § evalFuncPkgParamVarSelKeepsCall237
// select in a nested callee called from an if condition not taken
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned in(int unsigned i);
    return ENC[i];
  endfunction
  function automatic int unsigned fw(int unsigned i);
    automatic int unsigned r = 3;
    if (i > 100)
      if (in(i) > r) r = in(i);
    return r;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
