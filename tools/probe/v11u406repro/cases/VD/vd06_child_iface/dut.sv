// § deferredAssertItemDropped406
interface bus(input logic clk);
  logic v;
  assert #0 (v !== 1'bx);
  cover final (v);
endinterface
module child(bus b);
  assume #0 (b.v);
endmodule
module top(input logic clk);
  bus b0(clk);
  child c0(b0);
endmodule
