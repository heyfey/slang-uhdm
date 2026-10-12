// § pureProtoInlineAggSpans301
virtual class b;
  pure virtual function void f(input struct packed { logic a; } v [2]);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
