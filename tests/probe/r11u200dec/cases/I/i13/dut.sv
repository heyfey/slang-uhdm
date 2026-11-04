interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
program tc(oif.OP o[1:0]);
endprogram
module top; bit clk; oif oa[1:0](clk); tc TC(.o(oa)); endmodule
