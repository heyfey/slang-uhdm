// § pureProtoInlineAggSpans301
virtual class b;
  pure virtual function logic [3:0] f(input struct packed { logic a; logic b; } v);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
