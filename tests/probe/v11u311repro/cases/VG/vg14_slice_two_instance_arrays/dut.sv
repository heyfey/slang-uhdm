// § genScopeIfaceArrTailDup311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  if (1) begin : g
    ifc farr [2] ();
    child a [2] (.p(farr), .o(o[1:0]));
    child b [2] (.p(farr), .o(o[3:2]));
  end
endmodule
