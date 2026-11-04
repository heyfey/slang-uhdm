// § escNameSpanSites295
module child #(parameter int W = 1) (input logic [W-1:0] a, output logic o); assign o = ^a; endmodule
module dut (input logic [3:0] a, output logic o);
  child #(.W(4)) \u.prm (.a(a), .o(o));
endmodule
