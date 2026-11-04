module v03(input logic [7:0] m, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    logic [7:0] x = 8'd5;
    logic [7:0] a = x;
    logic [7:0] d = k;
  end
endmodule
