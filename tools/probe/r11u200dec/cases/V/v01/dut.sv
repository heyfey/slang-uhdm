module v01(input logic [7:0] m, output logic [7:0] o);
  parameter P = 3;
  if (1) begin : g1
    logic [7:0] x = 8'd5;
    logic [7:0] a = x;
    logic [7:0] d = x[3:0];
    logic [7:0] h = ~x;
    int i = $bits(x);
  end
endmodule
