// § escNameSpanSites295
interface ifc; logic d; endinterface
module child(ifc \i.f , output logic b);
  assign b = \i.f .d;
endmodule
module top(output logic b);
  ifc i();
  child u (.\i.f (i), .b(b));
endmodule
