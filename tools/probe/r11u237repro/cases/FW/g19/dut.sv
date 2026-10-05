// § evalFuncPkgParamVarSelKeepsCall237
// the call inside a generate block
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  if (M > 0) begin : g
    assign o = q::fw(M);
  end else begin : h
    assign o = 0;
  end
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
