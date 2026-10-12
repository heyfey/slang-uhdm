// § escNameSpanSites295
interface ifc; logic d; endinterface
module dut (output logic o);
  ifc \i.arr [1:0] ();
  assign \i.arr [0].d = 1'b1;
  assign o = \i.arr [0].d;
endmodule
