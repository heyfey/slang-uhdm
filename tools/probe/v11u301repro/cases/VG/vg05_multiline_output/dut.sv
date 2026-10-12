// § pureProtoInlineAggSpans301
virtual class b;
  pure virtual function void f(output struct packed {
                                 logic a;
                                 logic b;
                               } [1:0] v);
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
