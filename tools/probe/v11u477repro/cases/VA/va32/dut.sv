// § caAddLeafIntMint477
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  parameter logic [7:0] Q = 8'd5;
  localparam int unsigned U = 8'd200 + 8'd100;
  assign z = U[7:0];
endmodule
