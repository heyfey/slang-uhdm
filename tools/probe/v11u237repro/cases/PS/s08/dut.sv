// § evalFuncPkgParamVarSelKeepsCall237
// package q's function calls package r's function that selects r's parameter by its formal
package r;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned g(int unsigned i);
    return ENC[i];
  endfunction
endpackage
package q;
  function automatic int unsigned fw(int unsigned i);
    return r::g(i) + 1;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(1)) u (.o(o));
endmodule
