// § pureProtoInlineAggSpans301
virtual class b;
  pure virtual function void f(input struct packed { logic a; } [1:0] v, struct packed { logic c; } [2:0] w);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
