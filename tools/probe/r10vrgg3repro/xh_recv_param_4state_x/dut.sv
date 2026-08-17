interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter logic [31:0] AW = 32'hx)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
