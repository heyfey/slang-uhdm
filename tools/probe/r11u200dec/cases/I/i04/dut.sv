interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
module tc(oif o[2]);
  assign o[0].r = o[1].d[0];
endmodule
module top; bit clk; oif oa[2](clk); tc TC(oa); endmodule
