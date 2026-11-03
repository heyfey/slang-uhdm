// § caAddLeafIntMint477
module sub(input logic [7:0] i, output logic [7:0] o);
  assign o = i;
endmodule
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  sub u(.i(P + 8'd1), .o(z));
endmodule
