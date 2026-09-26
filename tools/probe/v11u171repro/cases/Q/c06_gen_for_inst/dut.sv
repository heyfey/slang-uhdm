// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [3:0] w13, input [3:0] w135, output [3:0] w141);
for (genvar i = 0; i < 2; i++) begin : g
  ch a142 ({w13[2*i], w13[2*i+1]}, w135[2*i+1:2*i], w141[2*i+1:2*i]);
end
endmodule
