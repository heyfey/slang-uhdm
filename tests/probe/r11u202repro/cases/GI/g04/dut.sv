// § defGenInitBitSelAtIndex202
module g04(input logic [7:0] m, output logic [7:0] o);
  logic [7:0] q;
  for (genvar i = 0; i < 2; i++) begin : gf
    logic c = q[i];
    logic d = q[(1)];
    logic e = q[0] & m[1];
  end
  assign o = m;
endmodule
