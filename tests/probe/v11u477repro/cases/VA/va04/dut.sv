// § caAddLeafIntMint477
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  parameter logic [7:0] Q = 8'd5;
  localparam bit C = 1;
  assign z = C ? P + 8'd1 : 8'd0;
endmodule
