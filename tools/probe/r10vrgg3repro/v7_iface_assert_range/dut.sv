interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  logic [AW-9:0] narrow;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 4)(itf.mp p[3]);
endmodule
module top;
  itf #(16) arr[3]();
  recv u (.p(arr));
endmodule
