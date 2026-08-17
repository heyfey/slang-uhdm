interface itf #(parameter int AW = 4);
  logic [7:0] mem [AW];
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 2)(itf.mp p[3]);
endmodule
module top;
  itf #(4) arr[3]();
  recv u (.p(arr));
endmodule
