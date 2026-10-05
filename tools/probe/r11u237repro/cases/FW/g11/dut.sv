// § evalFuncPkgParamVarSelKeepsCall237
// element select of a package unpacked int-array parameter
package q;
  localparam int unsigned ENC [3] = '{4, 3, 2};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
