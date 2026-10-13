// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child #(parameter int W = 1) (ifc.mp p, output logic o);
  assign o = p.sig[W-1];
endmodule
module top (output logic [1:0] o);
  ifc farr [2] ();
  child #(.W(1)) c0 (farr[0], o[0]);
  child #(.W(2)) c1 (farr[1], o[1]);
endmodule
