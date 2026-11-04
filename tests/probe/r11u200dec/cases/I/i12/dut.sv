interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
program tc(oif.OP o[2], oif.OP p);
endprogram
module top; bit clk; oif oa[2](clk); oif ob(clk); tc TC(oa, ob); endmodule
