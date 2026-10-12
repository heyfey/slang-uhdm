// § genConnSelBaseNameTrim303
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module vleaf (input logic [1:0] p);
  wire [1:0] w; assign w = p;
endmodule
module top (input logic [7:0] arr);
  for (genvar i = 0; i < 2; ++i) begin : g
    for (genvar j = 0; j < 2; ++j) begin : h
      nleaf n (.p (arr  [2*i+j]));
    end
  end
endmodule
