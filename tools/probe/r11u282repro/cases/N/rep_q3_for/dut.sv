// § genCaReplCountUnsizedClone282
module top #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  for (genvar x = 0; x < 1; x++) begin : g
    assign z[7:0] = b[P] | '0;
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top #(.P(5)) u (.b(b), .z(z), .zz(zz)); endmodule
