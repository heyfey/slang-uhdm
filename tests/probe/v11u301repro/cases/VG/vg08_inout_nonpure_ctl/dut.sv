// § pureProtoInlineAggSpans301
virtual class b;
  virtual function void f(inout struct packed { logic a; } [1:0] v); endfunction
endclass
module dut (output logic [3:0] o);
  b h;
  initial o = 4'h5;
endmodule
