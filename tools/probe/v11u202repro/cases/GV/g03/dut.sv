// § defGenInitBitSelAtIndex202
module g03 (input logic [7:0] x, output logic o);
  logic [7:0] q;
  logic [1:0][3:0] m;
  assign q = x;
  assign m = x;
  if (1) begin : g1
    logic a = q[(1)];
    logic b = q[q[0]];
    logic c = m[1][2];
    logic d = {q[1], q[2]} == 2'b01;
    logic e = ~q[3];
  end
  assign o = g1.a ^ g1.b ^ g1.c ^ g1.d ^ g1.e;
endmodule
