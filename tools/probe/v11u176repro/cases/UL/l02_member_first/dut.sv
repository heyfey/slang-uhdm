// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
typedef struct packed { logic a; logic b; } s_t;
module dut(input s_t s, input w, output [1:0] q);
  ch a1({s.a, w}, {w, 1'b1}, q);
endmodule
