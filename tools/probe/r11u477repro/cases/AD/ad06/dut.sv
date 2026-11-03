// § caAddLeafIntMint477
module top(output logic [7:0] z, output logic [7:0] w);
  parameter logic [7:0] P = 8'd33;
  assign z = P + 1;
  assign w = (P + 1) & 8'hff;
endmodule
