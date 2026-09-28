// § ifaceArrPortElemViewNamedByArray200
interface oif;
  logic [7:0] d;
  modport OP(input d);
endinterface
module leaf(oif.OP o[2][2][2], output logic [7:0] y);
  assign y = o[1][1][0].d;
endmodule
module top(output logic [7:0] y);
  oif oa[2][2][2]();
  leaf l(oa, y);
endmodule
