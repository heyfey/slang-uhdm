// § genCaReplCountUnsizedClone282
module top #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z);
  for (genvar x = 0; x < 1; x++) begin : g
    assign z[7:0] = {P{b[0]}};
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z); top #(.P(5)) u (.b(b), .z(z)); endmodule
