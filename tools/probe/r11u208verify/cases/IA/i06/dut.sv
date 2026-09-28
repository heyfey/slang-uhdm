// § ifaceArrPortElemViewNamedByArray200
interface oif(input bit clock, input bit rst);
  logic [7:0] d;
endinterface
program tc(oif o[3]);
  initial $display(o[2].d, o[0].clock);
endprogram
module top; bit clk, rst; oif oa[3](clk, rst); tc TC(oa); endmodule
