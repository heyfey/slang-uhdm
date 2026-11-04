interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
program tc(oif.OP o[2]);
endprogram
module mid; bit clk; oif oa[2](clk); tc TC(oa); endmodule
module top; mid u(); endmodule
