// § ifcConcAssertListed424 (control: pass 421 residue ra02, the module road)
module m(input bit clk, input read, write);
  assert property (@(posedge clk) !(read & write)) else $error("x");
endmodule
module top; bit c; logic r, w; m dif(c, r, w); endmodule
