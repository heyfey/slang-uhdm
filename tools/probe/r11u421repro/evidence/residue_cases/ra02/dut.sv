// residue (no law landed): the same assertion in a module, STRICT_EQUAL control, see README
module m(input bit clk, input read, write);
  assert property (@(posedge clk) !(read & write)) else $error("x");
endmodule
module top; bit c; logic r, w; m dif(c, r, w); endmodule
