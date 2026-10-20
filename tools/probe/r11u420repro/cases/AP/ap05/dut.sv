// § ansiNoDirNetPortUntyped420
module m(wire [31:0] bus, logic clk);
  logic r;
  always @(posedge clk) r <= bus[0];
endmodule
