// § ifcConcAssertListed424
interface ifc(output bit clk, input read, input write);
  assert property (@(posedge clk) !(read & write)) else $error("x");
endinterface
module top();
  ifc dif();
  initial dif.clk = 0;
endmodule
