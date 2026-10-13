// § genScopeIfaceArrayElems311
interface ifc #(parameter int N = 2);
  logic [7:0] sig;
  if (N > 1) begin : gi
    logic extra;
  end
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  if (1) begin : g
    ifc #(.N(3)) farr [2] ();
    child c0 (.p(farr[0]), .o(o[0]));
    child c1 (.p(farr[1]), .o(o[1]));
  end
endmodule
