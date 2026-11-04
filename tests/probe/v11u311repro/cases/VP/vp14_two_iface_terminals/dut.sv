// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, ifc.mp q, output logic o);
  assign o = p.sig[0] ^ q.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc farr [2] ();
  ifc garr [2] ();
  child c0 (farr[0], garr[1], o[0]);
  child c1 (farr[1], garr[0], o[1]);
endmodule
