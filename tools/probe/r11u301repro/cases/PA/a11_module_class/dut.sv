// § pureProtoInlineAggSpans301
module dut (output logic [3:0] o);
  virtual class b;
    pure virtual function struct packed { logic a; } [1:0] f(input struct packed { logic a; } [2:0] v);
  endclass
  b h;
  initial o = 4'h5;
endmodule
