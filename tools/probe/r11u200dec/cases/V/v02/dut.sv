module v02(input logic [7:0] m, output logic [7:0] o);
  parameter P = 3;
  if (1) begin
    logic [7:0] x = 8'd5;
    logic [7:0] a = x;
    logic [7:0] d = x[3:0];
  end
endmodule
