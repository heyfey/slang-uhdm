interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  logic [AW-1:0] c;
  assign c = AW;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
