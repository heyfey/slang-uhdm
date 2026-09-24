interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int N = 100)(itf.mp p[3]);
  localparam int AW = $clog2(N);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
