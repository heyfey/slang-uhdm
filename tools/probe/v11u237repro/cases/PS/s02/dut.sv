// § evalFuncPkgParamVarSelKeepsCall237
// element select of an unpacked int array package parameter by a formal
package q;
  localparam int T [4] = '{1, 2, 3, 4};
  function automatic int fw(int unsigned i);
    return T[i];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
