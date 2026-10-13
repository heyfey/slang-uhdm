// § genScopeIfaceArrTailDup311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  if (1) begin : g
    ifc farr [4] ();
    child a [2] (.p(farr[0:1]), .o(o));
  end
endmodule
