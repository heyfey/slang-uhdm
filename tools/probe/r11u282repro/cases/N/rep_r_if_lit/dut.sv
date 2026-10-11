// § genCaReplCountUnsizedClone282
module top #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z);
  if (1) begin : g
    assign z[7:0] = {P{1'b1}};
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z); top #(.P(5)) u (.b(b), .z(z)); endmodule
