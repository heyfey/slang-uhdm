module sub (input logic c, input logic [31:0] x, output logic [31:0] z);
  for (genvar i = 0; i < $bits(x[1:0]); i++) begin : g
    assign z[i] = x[i];
  end
endmodule
module top (input logic c, input logic [31:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
