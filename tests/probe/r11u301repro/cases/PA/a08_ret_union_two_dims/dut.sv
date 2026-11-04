// § pureProtoInlineAggSpans301
virtual class b;
  pure virtual function union packed { logic [1:0] a; logic [1:0] b; } [1:0][2:0] f();
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
