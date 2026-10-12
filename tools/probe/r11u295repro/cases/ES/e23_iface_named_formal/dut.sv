// § escNameSpanSites295
interface ifc; logic d; modport mp (input d); endinterface
module child (ifc.mp \p.m , output logic o); assign o = \p.m .d; endmodule
module dut (output logic o);
  ifc u_i ();
  assign u_i.d = 1'b0;
  child u_c (.\p.m (u_i.mp), .o(o));
endmodule
