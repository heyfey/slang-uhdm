// § pureProtoInlineAggSpans301
virtual class b;
  pure virtual function void f(input union packed { logic [1:0] a; logic [1:0] b; } [2:0] v);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
