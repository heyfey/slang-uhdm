// § genCaFoldTsChainNamed169
module child #(parameter int P = 6) (input logic [31:0] a [2], output logic [31:0] o [2][2]);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      assign o[i][j] = (a[i] > P) ? a[j][P +: 4] : {a[i][P], 31'b0} | P;
    end
  end
endmodule
module dut (input logic [31:0] a [2], output logic [31:0] o [2][2], output logic [31:0] q [2][2]);
  child #(.P(3)) u (.a(a), .o(o));
  child v (.a(a), .o(q));
endmodule
