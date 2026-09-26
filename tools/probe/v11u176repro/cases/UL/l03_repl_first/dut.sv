// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input w, output [1:0] q);
  ch a1({2{w}}, {w, 1'b1}, q);
endmodule
