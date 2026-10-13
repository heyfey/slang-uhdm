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
    ifc farr [3:2] ();
    child a [1:0] (.p(farr), .o(o));
  end
endmodule
