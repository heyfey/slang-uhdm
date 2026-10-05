// § evalFuncPkgParamVarSelKeepsCall237
// the cont_assign inside an interface
package q;
  localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned i);
    return ENC[i];
  endfunction
endpackage
interface ifc #(parameter int unsigned M = 0) ();
  logic [31:0] o;
  assign o = q::fw(M);
endinterface
module top (output logic [31:0] o);
  ifc #(.M(2)) u ();
  assign o = u.o;
endmodule
