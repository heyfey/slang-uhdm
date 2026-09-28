// § ifaceArrPortElemViewNamedByArray200
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, input d);
endinterface
program tc(oif.OP o[1:0]);
  initial $display(o[1].d);
endprogram
module mc(oif.OP o[1:0], output logic [7:0] y);
  assign y = o[0].d;
endmodule
module top(output logic [7:0] y); bit clk; oif oa[1:0](clk); tc TC(oa); mc M(oa, y); endmodule
