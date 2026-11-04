// § ifcConcAssertListed424 (control: no assertion, named connections)
interface ifc(input bit clk, input read, write);
  logic q;
endinterface
module top;
  bit c; logic r, w;
  ifc dif(.clk(c), .read(r), .write(w));
endmodule
