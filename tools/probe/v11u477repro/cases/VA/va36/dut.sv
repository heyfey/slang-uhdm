// § caAddLeafIntMint477
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  localparam logic [7:0] L = P + 8'd1;
  logic [L:0] y;
  assign z = y[7:0];
endmodule
