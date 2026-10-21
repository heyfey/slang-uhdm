// § ifcConcAssertListed424 (pass 421 residue ra01: positional connections)
interface ifc(input bit clk, input read, write);
  assert property (@(posedge clk) !(read & write)) else $error("x");
endinterface
module top; bit c; logic r, w; ifc dif(c, r, w); endmodule
