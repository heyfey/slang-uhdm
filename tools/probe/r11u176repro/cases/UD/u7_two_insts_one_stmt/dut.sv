// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] p, q);
  ch a1(p, q, x), a2({1'b1, p[0]}, q, y);
endmodule
