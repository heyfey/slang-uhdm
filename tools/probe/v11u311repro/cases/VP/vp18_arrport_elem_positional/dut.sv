// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module mid (ifc.mp pa [2], output logic [1:0] o);
  child c0 (pa[0], o[0]);
  child c1 (pa[1], o[1]);
endmodule
module top (output logic [1:0] o);
  ifc farr [2] ();
  mid m (.pa(farr), .o(o));
endmodule
