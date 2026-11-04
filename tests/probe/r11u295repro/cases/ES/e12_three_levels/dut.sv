// § escNameSpanSites295
module leaf (input logic a, output logic o); assign o = ~a; endmodule
module mid (input logic a, output logic o);
  leaf \l.f (.a(a), .o(o));
endmodule
module dut (input logic a, output logic o);
  mid \m.d (.a(a), .o(o));
endmodule
