// § genProcUnaryFoldInst282
module c #(parameter int P = 4) (input logic [7:0] a [2], output logic [7:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = a[w] ^ -P;
  end
endmodule
module top(input logic [7:0] a [2], output logic [7:0] z1 [2], z2 [2]); c u1(.a(a), .z(z1)); c #(.P(6)) u2(.a(a), .z(z2)); endmodule
