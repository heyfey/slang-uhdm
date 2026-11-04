// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module c1p (ifc.mp p);
  logic q;
  assign q = p.sig[0];
endmodule
module top;
  ifc farr [2] ();
  c1p c0 (farr[0]);
  c1p c1 (farr[1]);
endmodule
