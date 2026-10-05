// § evalFuncPkgParamVarSelKeepsCall237
// a literal argument (no parameter) to the selecting function
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i];
  endfunction
endpackage
module top (output logic [31:0] o);
  assign o = q::fw(1);
endmodule
