// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module tgt (output logic o);
  assign o = 1'b0;
endmodule
module mon (output logic [1:0] m);
  ifc farr [2] ();
  child c0 (farr[0], m[0]);
  child c1 (farr[1], m[1]);
endmodule
module top (output logic o);
  tgt t (.o(o));
  bind tgt mon mb (.m());
endmodule
