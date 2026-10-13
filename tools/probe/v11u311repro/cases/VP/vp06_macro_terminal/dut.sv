// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
`define EL(n) farr[n]
module top (output logic [1:0] o);
  ifc farr [2] ();
  child c0 (`EL(0), o[0]);
  child c1 (`EL(1), o[1]);
endmodule
