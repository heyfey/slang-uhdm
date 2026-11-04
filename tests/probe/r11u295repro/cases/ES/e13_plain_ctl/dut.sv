// § escNameSpanSites295
module child (input logic a, output logic o); assign o = a; endmodule
module dut (input logic a, output logic o);
  child u_x (.a(a), .o(o));
endmodule
