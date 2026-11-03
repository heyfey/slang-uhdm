// § caAddLeafIntMint477
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  parameter logic [7:0] Q = 8'd5;
  parameter int R = 3;
  logic [R + 4'd1 : 0] x;
  assign z = x;
endmodule
