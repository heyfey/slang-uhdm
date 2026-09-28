// § ndaRangeQueryFold216 — $high in a net initializer of a child instantiated twice with different widths
module sub #(parameter int W = 4) (input logic [W+1:2] i, output logic [7:0] o);
  wire [7:0] w = $high(i);
  assign o = w;
endmodule
module dut (input logic [9:2] i, output logic [7:0] o1, o2);
  sub #(.W(4)) a (.i(i[5:2]), .o(o1));
  sub #(.W(8)) b (.i(i), .o(o2));
endmodule
