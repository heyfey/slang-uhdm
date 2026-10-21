// § ifcConcAssertListed424 (control: an interface without an assertion)
interface ifc(input bit clk, input read, write);
  logic q;
  always @(posedge clk) q <= read & write;
endinterface
module top; bit c; logic r, w; ifc dif(c, r, w); endmodule
