// § escNameSpanSites295
interface ifc; logic d; modport mp (input d); endinterface
module child (ifc.mp p, output logic o); assign o = p.d; endmodule
module dut (output logic o);
  ifc \i.f ();
  assign \i.f .d = 1'b1;
  child u_c (.p(\i.f ), .o(o));
endmodule
