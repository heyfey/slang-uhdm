// § evalFuncPkgParamVarSelKeepsCall237
// indexed part-select of a packed vector package parameter by a formal
package q;
  localparam logic [31:0] P = 32'h12345678;
  function automatic logic [7:0] fy(int unsigned i);
    return P[i*8 +: 8];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [7:0] o);
  assign o = q::fy(M);
endmodule
module top (output logic [7:0] o);
  sub #(.M(1)) u (.o(o));
endmodule
