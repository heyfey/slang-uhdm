// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic [7:0] mem [int];
  always @(posedge clk) mem[3] <= 8'h1;
  always @(negedge clk) $display("%b", undecl_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
