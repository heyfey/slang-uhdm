interface itf #(parameter int AW = 16);
  logic [0:AW-1] a;
  logic [AW:AW+7] rv;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 3)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
