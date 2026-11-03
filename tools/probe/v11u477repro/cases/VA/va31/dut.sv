// § caAddLeafIntMint477
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  parameter logic [7:0] Q = 8'd5;
  logic [7:0] n;
  assign n = 8'd3;
  assign z = n + 8'd1 + P;
endmodule
