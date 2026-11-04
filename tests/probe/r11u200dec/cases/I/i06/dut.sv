interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
module t2(oif.OP p[2]);
endmodule
module tc(oif.OP o[2]);
  t2 u(o);
endmodule
module top; bit clk; oif oa[2](clk); tc TC(oa); endmodule
