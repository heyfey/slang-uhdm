// § escNameSpanSites295
interface ifc; logic d; modport mp(input d); endinterface
module child(ifc.mp \p.q , output logic b);
  assign b = \p.q .d;
endmodule
module top(output logic b);
  ifc i();
  child u (.\p.q (i), .b(b));
endmodule
