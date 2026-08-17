interface itf #(parameter int AW = 2);
  logic [AW-1:0] a;
  for (genvar i = 0; i < AW; i++) begin : gl
    logic w;
  end
  modport mp (input a);
endinterface
module recv #(parameter int AW = 3000)(itf.mp p[3]);
endmodule
module top;
  itf #(2) arr[3]();
  recv u (.p(arr));
endmodule
