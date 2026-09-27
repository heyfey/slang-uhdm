// § macroIfacePathTokSpans183 (a procedural lvalue in a macro)
`define drv(RIF, CLK) \
    always_ff @(posedge CLK) RIF.read_data[1] <= 1'b1;
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if, input logic clk);
  `drv(bit_field_if, clk)
endmodule
module top(input logic clk);
  bif b();
  m u(.bit_field_if(b), .clk(clk));
endmodule
