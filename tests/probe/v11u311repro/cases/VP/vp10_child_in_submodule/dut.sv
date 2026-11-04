// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module mid (output logic [1:0] o);
  ifc farr [2] ();
  child c0 (farr[0], o[0]);
  child c1 (farr[1], o[1]);
endmodule
module top (output logic [3:0] o);
  mid m0 (o[1:0]);
  mid m1 (o[3:2]);
endmodule
