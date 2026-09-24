interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  if (AW > 8) begin : gbig
    logic big;
  end else begin : gsml
    logic sml;
  end
  modport mp (input a);
endinterface
module recv #(parameter int AW = 4)(itf.mp p[3]);
endmodule
module top;
  itf #(16) arr[3]();
  recv u (.p(arr));
endmodule
