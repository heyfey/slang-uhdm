// § pureProtoInlineAggSpans301
typedef struct packed { logic a; logic b; } s_t;
virtual class b;
  pure virtual function s_t [1:0] f(input s_t [1:0] v);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
