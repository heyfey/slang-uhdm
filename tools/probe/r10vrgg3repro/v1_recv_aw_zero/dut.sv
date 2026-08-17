interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 0)(itf.mp p[3]);
  logic [AW:0] own;
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
