// § escNameSpanSites295
interface ifc; logic d; endinterface
interface ifc2(ifc \i.f );
  logic e;
  assign e = \i.f .d;
endinterface
module top(output logic o);
  ifc i();
  ifc2 j (.\i.f (i));
  assign o = j.e;
endmodule
