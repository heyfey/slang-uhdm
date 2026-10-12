// § pureProtoInlineAggSpans301
interface class ic;
  pure virtual function struct packed { logic a; } [1:0] f(ref struct packed { logic a; } [2:0] v);
endclass
module dut (output logic [3:0] o);
  initial o = 4'h5;
endmodule
