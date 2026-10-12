// § pureProtoInlineAggSpans301
`define ST struct packed { logic a; logic b; } [1:0]
virtual class b;
  pure virtual function `ST f(input `ST v);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
