interface itf #(parameter int AW = 4);
  localparam int Q = 64 / AW;
  logic [Q-1:0] q;
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 0)(itf.mp p[3]);
endmodule
module top;
  itf #(4) arr[3]();
  recv u (.p(arr));
endmodule
