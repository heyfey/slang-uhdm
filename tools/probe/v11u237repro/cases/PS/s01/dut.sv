// § evalFuncPkgParamVarSelKeepsCall237
// bit-select of a packed vector package parameter by a formal
package q;
  localparam logic [7:0] P = 8'hA5;
  function automatic logic fb(int unsigned i);
    return P[i];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic o);
  assign o = q::fb(M);
endmodule
module top (output logic o);
  sub #(.M(2)) u (.o(o));
endmodule
