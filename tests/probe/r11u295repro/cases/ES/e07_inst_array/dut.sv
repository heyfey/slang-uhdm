// § escNameSpanSites295
module child (input logic a, output logic o); assign o = a; endmodule
module dut (input logic [1:0] a, output logic [1:0] o);
  child \u.arr [1:0] (.a(a), .o(o));
endmodule
