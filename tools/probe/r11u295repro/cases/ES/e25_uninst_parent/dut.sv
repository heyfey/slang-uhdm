// § escNameSpanSites295
module child (input logic a, output logic o); assign o = a; endmodule
module m_unused #(parameter int P) (input logic a, output logic o);
  child \u.un (.a(a), .o(o));
endmodule
module dut (input logic a, output logic o);
  assign o = a;
endmodule
