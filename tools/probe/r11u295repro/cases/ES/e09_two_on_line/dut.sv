// § escNameSpanSites295
module child (input logic a, output logic o); assign o = a; endmodule
module dut (input logic [1:0] a, output logic [1:0] o);
  child \u.a (.a(a[0]), .o(o[0])), \u.b (.a(a[1]), .o(o[1]));
endmodule
