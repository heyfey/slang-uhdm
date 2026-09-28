// § ifaceArrPortElemViewNamedByArray200
interface oif(input bit clock);
  logic [7:0] d;
  logic r;
  modport OP(input clock, input d, output r);
  modport IP(input clock, output d, input r);
endinterface
module cons(oif.OP o[2][2], output logic [7:0] y);
  assign y = o[1][0].d ^ o[0][1].d;
  assign o[1][1].r = 1'b1;
endmodule
module top(input bit clk, output logic [7:0] y);
  oif oa[2][2](clk);
  cons c(.o(oa), .y(y));
endmodule
