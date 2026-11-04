// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a);
  assert property (@(posedge clk) a) $display("ok"); else $display("ko");
  assert final (a);
  initial assert (a);
endinterface
module top; bit c; logic x; ifc u(c, x); endmodule
