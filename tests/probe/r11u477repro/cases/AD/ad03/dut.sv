// § caAddLeafIntMint477
module top(output logic [7:0] z);
  localparam logic [7:0] P = 8'd33;
  assign z = 8'h10 + P;
endmodule
