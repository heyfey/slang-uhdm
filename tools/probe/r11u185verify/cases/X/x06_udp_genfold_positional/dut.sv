// § udpFormNetLvalueFirst176 § genCaFoldTsChainNamed169
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] w [2], input [1:0] x, output [1:0] o [2], output [1:0] p [2]);
  localparam int P = 1;
  for (genvar g = 0; g < 2; g++) begin : L
    ch a(w[g], x, o[g]);
    ch b({1'b0, w[g][P]}, x, p[g]);
  end
endmodule
