// § genVarInitOuterRefUnbound202
module g01 #(parameter P = 3) (input logic [7:0] x, output logic [7:0] o);
  logic [7:0] q;
  assign q = x;
  if (1) begin : g1
    logic [7:0] a = q[3:0];
    logic [7:0] b = q[P];
    logic [7:0] c = {x, q};
    logic [7:0] d = f(q);
    logic [7:0] e = $signed(x);
    logic [7:0] h = P;
  end
  function automatic logic [7:0] f(input logic [7:0] y); return y; endfunction
  assign o = g1.a ^ g1.b ^ g1.c ^ g1.d ^ g1.e ^ g1.h;
endmodule
