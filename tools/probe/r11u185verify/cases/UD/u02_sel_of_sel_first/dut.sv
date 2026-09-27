// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0][1:0] m, input [3:0] v, output [1:0] o, p);
  ch a1(m[1], m[0], o);
  ch a2(m[1][1:0], m[0], p);
endmodule
