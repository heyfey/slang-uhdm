// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc farr [1:2] ();
  child c0 (farr[1], o[0]);
  child c1 (farr[2], o[1]);
endmodule
