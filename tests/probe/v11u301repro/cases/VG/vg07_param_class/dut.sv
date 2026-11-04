// § pureProtoInlineAggSpans301
virtual class b #(parameter int N = 2);
  pure virtual function void f(input struct packed { logic [N-1:0] a; } [1:0] v);
endclass
module dut (output logic [3:0] o);
  b #(3) h;
  initial o = 4'h5;
endmodule
