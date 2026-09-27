// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [3:0] w1, w2, output [3:0] o, p);
  ch a1 [1:0] (w1, w2, o);
  ch a2 [1:0] ({2'b00, w1[1:0]}, w2, p);
endmodule
