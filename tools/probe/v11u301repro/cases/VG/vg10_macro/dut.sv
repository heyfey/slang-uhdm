// § pureProtoInlineAggSpans301
`define ST struct packed { logic a; logic b; }
virtual class b;
  pure virtual function `ST [1:0] f(input `ST [2:0] v);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
