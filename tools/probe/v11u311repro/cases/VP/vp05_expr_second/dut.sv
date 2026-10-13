// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, input logic a);
  logic o;
  assign o = p.sig[0] & a;
endmodule
module top (input logic x, y);
  ifc farr [2] ();
  child c0 (farr[0], x & y);
  child c1 (farr[1], x | y);
endmodule
