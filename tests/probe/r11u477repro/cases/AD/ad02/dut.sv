// § caAddLeafIntMint477
module top(output logic [7:0] z);
  localparam logic [7:0] P = 8'h21;
  assign z = P + 8'd1;
endmodule
