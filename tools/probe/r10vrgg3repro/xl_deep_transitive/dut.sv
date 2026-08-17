interface itf #(parameter int AW = 16, parameter int B1 = AW*2,
                parameter int B2 = B1+1, parameter int B3 = B2*2);
  logic [B3-1:0] a;
  logic [AW-1:0] s;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 3)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
