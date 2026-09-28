interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
module tc(interface o[2]);
endmodule
module top; bit clk; oif oa[2](clk); tc TC(oa); endmodule
