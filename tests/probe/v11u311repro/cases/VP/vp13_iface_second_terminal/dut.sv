// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (output logic o, ifc.mp p);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc farr [2] ();
  child c0 (o[0], farr[0]);
  child c1 (o[1], farr[1]);
endmodule
