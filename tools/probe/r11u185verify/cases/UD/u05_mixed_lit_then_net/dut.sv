// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] w1, w2, output [1:0] o, p);
  ch a1(2'b01, w1, o), a2(w1, w2, p);
endmodule
