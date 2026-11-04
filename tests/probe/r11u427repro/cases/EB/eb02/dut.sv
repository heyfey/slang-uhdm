// § sgnBinElabIntBranchStands427
module sub #(parameter D = 4'sb1010, parameter E = 4'SB1001, parameter G = 4'sb0101, parameter H = 2'sb11)(input a, output o);
  assign o = a;
endmodule
module top(input a, output o);
  sub u(.a(a), .o(o));
endmodule
