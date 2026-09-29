// § ndaAdjSizeFoldSized223
module sub #(parameter int N = 3, parameter int W = 4) (output logic [7:0] o);
  bit [N-1:0][1:0] bp;
  wire [W-1:0] w = $size(bp);
  assign o = w;
endmodule
module dut (output logic [7:0] o1, o2);
  sub #(.N(5), .W(3)) u1 (.o(o1));
  sub #(.N(9), .W(8)) u2 (.o(o2));
endmodule
