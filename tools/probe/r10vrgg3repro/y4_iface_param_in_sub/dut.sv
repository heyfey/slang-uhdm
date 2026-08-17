module leaf #(parameter int W = 1)(input logic [W-1:0] i);
endmodule
interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  leaf #(AW) ul (.i(a));
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
