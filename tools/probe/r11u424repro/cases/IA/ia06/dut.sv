// § ifcConcAssertListed424
interface ifc(input bit clk, input read, input write);
  assert property (@(posedge clk) !(read & write)) else $error("x");
endinterface
module top();
  bit c; logic r1, w1, r2, w2;
  ifc d1(.clk(c), .read(r1), .write(w1));
  ifc d2(.clk(c), .read(r2), .write(w2));
endmodule
