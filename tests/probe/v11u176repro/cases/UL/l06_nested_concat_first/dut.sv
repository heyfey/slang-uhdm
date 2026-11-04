// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input w, input v, input [1:0] p, output [1:0] q);
  ch a1({w, {v}}, {p[1], 1'b0}, q);
endmodule
