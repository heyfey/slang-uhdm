// § escNameSpanSites295
interface ifc; logic d; modport mp (input d); endinterface
module child (ifc \p.i , output logic o); assign o = \p.i .d; endmodule
module dut (output logic o);
  ifc u_i ();
  assign u_i.d = 1'b0;
  child \c.u (.\p.i (u_i), .o(o));
endmodule
