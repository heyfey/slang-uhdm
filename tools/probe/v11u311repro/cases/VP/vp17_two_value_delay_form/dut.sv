// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child #(parameter int A = 0, parameter int B = 0) (ifc.mp p, output logic o);
  assign o = p.sig[A+B];
endmodule
module top (output logic [1:0] o);
  ifc farr [2] ();
  child #(0, 1) c0 (farr[0], o[0]);
  child #(1, 0) c1 (farr[1], o[1]);
endmodule
