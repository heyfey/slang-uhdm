// § genScopeIfaceArrTailDup311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module recv (ifc.mp p[2], output logic o);
  assign o = p[0].sig[0] ^ p[1].sig[0];
endmodule
module top (output logic o);
  if (1) begin : g
    ifc farr [2] ();
    recv r (.p(farr), .o(o));
  end
endmodule
