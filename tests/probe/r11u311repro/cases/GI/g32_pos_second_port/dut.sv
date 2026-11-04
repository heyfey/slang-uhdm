// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child2 (output logic o, ifc.mp p);
  assign o = p.sig[1];
endmodule
module top (output logic [1:0] o);
  ifc farr [2] ();
  child2 c0 (o[0], farr[0]);
  child2 c1 (o[1], farr[1]);
endmodule
