// § genScopeIfaceArrTailDup311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  ifc farr [2] ();
  child a [2] (.p(farr), .o(o[1:0]));
  if (1) begin : g
    ifc farr [2] ();
    child b0 (.p(farr[0]), .o(o[2]));
    child b1 (.p(farr[1]), .o(o[3]));
  end
endmodule
