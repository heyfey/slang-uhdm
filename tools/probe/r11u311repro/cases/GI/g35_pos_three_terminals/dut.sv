// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module c3 (ifc.mp p, input logic a, output logic o);
  assign o = p.sig[0] ^ a;
endmodule
module top (input logic a, output logic [1:0] o);
  ifc farr [2] ();
  c3 u0 (farr[0], a, o[0]);
  c3 u1 (farr[1], a, o[1]);
endmodule
