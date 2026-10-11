// § genCaSelBoundNestedOwner282
module top #(parameter int P = 3) (input logic [7:0] b, output logic [3:0] z);
  if (1) begin : gi
    wire [3:0] w = b[P:0] ^ 4'd1;
    assign z = w;
  end
endmodule
module wrap(input logic [7:0] b, output logic [3:0] z); top u (.b(b), .z(z)); endmodule
