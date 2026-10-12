// § genConnSelBaseNameTrim303
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module vleaf (input logic [1:0] p);
  wire [1:0] w; assign w = p;
endmodule
module top (input logic [3:0][1:0] bus);
  for (genvar i = 0; i < 2; ++i) begin : g
    vleaf a (.p (bus [i]));
  end
endmodule
