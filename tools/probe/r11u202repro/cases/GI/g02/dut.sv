// § defGenInitBitSelAtIndex202
module g02(input logic [7:0] m, output logic [7:0] o);
  logic [7:0] q;
  if (1) begin : g1
    logic [7:0] a = q + 8'd1;
    logic [3:0] b = q[3:0];
    logic c = q[0];
    logic [15:0] d = {q, m};
    logic [7:0] e = ~m;
  end
  assign o = m;
endmodule
