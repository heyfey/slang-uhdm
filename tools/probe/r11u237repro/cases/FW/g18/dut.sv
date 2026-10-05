// § evalFuncPkgParamVarSelKeepsCall237
// two instances, two overrides
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o, output logic [31:0] p);
  sub #(.M(2)) u (.o(o));
  sub #(.M(1)) v (.o(p));
endmodule
