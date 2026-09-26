// § boundLitWrittenDigits172
typedef struct packed { logic [03:00] a; logic [1_1:0_4] b; } s_t;
module sub(input s_t i, output logic [3:0] o);
  assign o = i.a;
endmodule
module dut(input s_t i, output logic [3:0] o, p);
  sub u0(i, o);
  sub u1(i, p);
endmodule
