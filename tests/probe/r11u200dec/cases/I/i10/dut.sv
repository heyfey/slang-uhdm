interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
program tc(interface o[2]);
endprogram
module top; bit clk; oif oa[2](clk); tc TC(oa); endmodule
