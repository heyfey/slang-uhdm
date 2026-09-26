// § ppOutputLine166 § ppOutputCol166
`define PASTEL(n) \
  assign n``_y = n``_a & \
    n``_b;
module top(input logic x_a, input logic x_b, output logic x_y, output logic z);
  `PASTEL(x) assign z = x_a;
endmodule
