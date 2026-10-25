// § sgnBinElabIntBranchStands427
module sub #(parameter D = 4'sb1010) (output [7:0] o);
  assign o = D;
endmodule
module top(output [7:0] o, o2);
  sub u(o);
  sub #(.D(4'sb0110)) u2(o2);
endmodule
