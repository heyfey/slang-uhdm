// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] w1, w2, output [1:0] o);
  ch a1(w1 & w2, w2, o);
endmodule
