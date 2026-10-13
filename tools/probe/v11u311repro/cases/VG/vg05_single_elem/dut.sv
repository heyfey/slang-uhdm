// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic o);
  if (1) begin : g
    ifc farr [0:0] ();
    child c0 (.p(farr[0]), .o(o));
  end
endmodule
