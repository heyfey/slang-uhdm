// § pureProtoInlineAggSpans301
interface class ic;
  pure virtual function void f(input struct packed { logic a; logic b; } [1:0] v);
endclass
module dut (output logic [3:0] o);
  initial o = 4'h5;
endmodule
