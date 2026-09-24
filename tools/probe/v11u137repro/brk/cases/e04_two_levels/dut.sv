// § connReplTsRefThroughPort137
module leaf(input logic [7:0] m, output logic [7:0] o);
  assign o = m;
endmodule
module mid(output logic [7:0] o);
  leaf l(.m({8{1'b1}}), .o(o));
endmodule
module top(output logic [7:0] o);
  mid u(.o(o));
endmodule
