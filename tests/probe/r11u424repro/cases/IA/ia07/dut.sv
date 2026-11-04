// § ifcConcAssertListed424
interface ifc(input bit clk, input read, input write);
  a1: assert property (@(posedge clk) !(read & write));
  m1: assume property (@(posedge clk) read |-> ##1 write);
  cover property (@(posedge clk) read);
endinterface
module top();
  bit c; logic r, w;
  ifc d(.clk(c), .read(r), .write(w));
endmodule
