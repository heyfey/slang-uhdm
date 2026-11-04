// § caAddLeafIntMint477
module sub #(parameter logic [7:0] P = 8'd2) (output logic [7:0] z);
  assign z = P + 8'd1;
endmodule
module top(output logic [7:0] z1, output logic [7:0] z2);
  sub u1(.z(z1));
  sub #(.P(8'h7)) u2(.z(z2));
endmodule
