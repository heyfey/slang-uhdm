// § evalFuncPkgParamVarSelKeepsCall237
// two-dimensional select of a packed 2-D package parameter by two formals
package q;
  localparam logic [1:0][2:0][3:0] T = '{'{4'd1, 4'd2, 4'd3}, '{4'd4, 4'd5, 4'd6}};
  function automatic logic [3:0] fw(int unsigned i, int unsigned j);
    return T[i][j];
  endfunction
endpackage
module sub #(parameter int unsigned M = 0, parameter int unsigned N = 0) (output logic [3:0] o);
  assign o = q::fw(M, N);
endmodule
module top (output logic [3:0] o);
  sub #(.M(1), .N(2)) u (.o(o));
endmodule
