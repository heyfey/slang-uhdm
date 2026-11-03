// § caAddLeafIntMint477
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  parameter logic [7:0] Q = 8'd5;
  localparam L = P + 8'd1;
  logic [L:0] y;
  assign z = L + 0;
endmodule
