// § genCaSelBoundNestedOwner282
module leaf #(parameter int P = 2) (input logic [7:0] b, output logic [1:0] z);
  for (genvar g = 0; g < 1; g++) begin : gb
    assign z = b[P +: 2] ^ 2'd1;
  end
endmodule
module mid #(parameter int Q = 1) (input logic [7:0] b, output logic [1:0] z); leaf #(.P(Q+1)) l(.b(b), .z(z)); endmodule
module top(input logic [7:0] b, output logic [1:0] z1, z2); mid m1(.b(b), .z(z1)); mid #(.Q(3)) m2(.b(b), .z(z2)); endmodule
