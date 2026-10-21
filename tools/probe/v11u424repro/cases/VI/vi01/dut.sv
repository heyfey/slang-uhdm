// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a, input logic b);
  a1: assert property (@(posedge clk) a |-> b) else $error("bad");
  always @(posedge clk) if (a) $display("a");
endinterface
module top; bit c; logic x, y, z, w;
  ifc u1(c, x, y);
  ifc u2(c, z, w);
endmodule
