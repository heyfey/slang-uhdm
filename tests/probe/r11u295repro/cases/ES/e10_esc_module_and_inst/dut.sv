// § escNameSpanSites295
module \c.hild (input logic a, output logic o); assign o = a; endmodule
module dut (input logic a, output logic o);
  \c.hild  \u.both  (.a(a), .o(o));
endmodule
