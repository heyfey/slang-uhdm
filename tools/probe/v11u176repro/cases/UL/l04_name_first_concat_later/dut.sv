// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] p, input w, output [1:0] q);
  ch a1(p, {1'b0, w}, q);
endmodule
