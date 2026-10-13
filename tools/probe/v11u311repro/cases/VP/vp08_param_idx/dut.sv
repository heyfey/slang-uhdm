// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  localparam int K = 1;
  ifc farr [2] ();
  child c0 (farr[K], o[0]);
  child c1 (farr[0], o[1]);
endmodule
