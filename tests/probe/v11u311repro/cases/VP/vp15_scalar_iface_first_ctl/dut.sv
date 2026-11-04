// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc fa ();
  ifc fb ();
  child c0 (fa, o[0]);
  child c1 (fb, o[1]);
endmodule
