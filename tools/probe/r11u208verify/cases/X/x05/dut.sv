// § newArrayArgPathElemsStripped200 § ifaceArrPortElemViewNamedByArray200
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, input d);
endinterface
program tc(oif.OP o[2]);
  int q[];
  initial begin
    q = new[o[1].d];
    q = new[o[0].d + 1](q);
  end
endprogram
module top; bit clk; oif oa[2](clk); tc TC(oa); endmodule
