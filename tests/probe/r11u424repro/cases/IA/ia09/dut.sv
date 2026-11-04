// § ifcConcAssertListed424
interface ifc(input bit clk, input read, input write);
  logic q;
  always @(posedge clk) q <= read;
  assert property (@(posedge clk) !(read & write)) else $error("x");
  modport mp(input q);
endinterface
module sub(ifc.mp p, output o);
  assign o = p.q;
endmodule
module top();
  bit c; logic r, w, o;
  ifc d(.clk(c), .read(r), .write(w));
  sub s(.p(d), .o(o));
endmodule
