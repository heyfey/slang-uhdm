// § genScopeIfaceArrayElems311
interface pifc #(parameter int W = 8);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface
module child (pifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  if (1) begin : g
    pifc #(.W(4)) farr [2] ();
    child c0 (.p(farr[0]), .o(o[0]));
    child c1 (.p(farr[1]), .o(o[1]));
  end
endmodule
