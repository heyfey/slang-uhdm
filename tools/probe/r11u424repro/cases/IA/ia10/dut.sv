// § ifcConcAssertListed424
interface ifc(input bit clk, input read, input write);
  assert property (@(posedge clk) !(read & write)) else $error("x");
endinterface
module mid(input bit c, input r, input w);
  ifc d(.clk(c), .read(r), .write(w));
endmodule
module top();
  bit c; logic r, w;
  mid m1(.c(c), .r(r), .w(w));
endmodule
