interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  logic clk;
  modport mp (input a, clk);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
  logic [AW-1:0] q;
  always_comb q = p[0].a;
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
