module sub #(parameter W = 4) (input logic c, input logic [31:0] x, output logic [31:0] z);
  for (genvar i = 0; i < 1; i++) begin : g
    assign z = $bits(x[W:0]);
  end
endmodule
module top (input logic c, input logic [31:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
