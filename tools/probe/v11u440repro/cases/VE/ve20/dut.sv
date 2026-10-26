// § errTypeTsLocAsVector440v
module m #(parameter x = "inv") (input signed [x-1:0][0:2] a, output wire signed [x-1:0][0:2] b);
  wire signed [x-1:0][0:2] n;
  logic [x-1:0][0:2] s = '0;
endmodule
module top; endmodule
