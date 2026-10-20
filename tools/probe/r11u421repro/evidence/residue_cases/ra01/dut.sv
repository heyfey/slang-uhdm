// residue (no law landed): an interface concurrent assertion listed as a process (sister ground, 16.12 property-interface), see README
interface ifc(input bit clk, input read, write);
  assert property (@(posedge clk) !(read & write)) else $error("x");
endinterface
module top; bit c; logic r, w; ifc dif(c, r, w); endmodule
