// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] w1, output [1:0] o, p);
  ch a1(2'b01, w1, o);
  ch a2({w1[0], 1'b1}, w1, p);
endmodule
