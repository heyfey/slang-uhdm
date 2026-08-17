interface itf #(parameter int AW = 16);
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5, parameter int LP = 100)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
