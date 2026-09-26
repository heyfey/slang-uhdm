// § udpFormConcatSwallowSpans171
module f3 (input [1:0] A, input B, input C, output Y);
  assign Y = ^A ^ B ^ C;
endmodule
module dut (input [1:0] w, input x, y, output z);
  typedef struct packed { logic a; logic b; } s_t;
  s_t s;
  assign s = w;
  f3 u ({s.a, s.b}, x, y);
endmodule
