interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
endinterface
program tc(oif.OP o[2]);
  initial $display(o[0].d);
endprogram
module top; bit clk; oif oa[2](clk); tc TC(.o(oa)); endmodule
