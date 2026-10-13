// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module chk (ifc.mp p, input logic o);
  logic q;
  assign q = p.sig[0] & o;
endmodule
module top (output logic o);
  ifc farr [2] ();
  assign o = 1'b0;
endmodule
bind top chk u_chk (farr[1], o);
