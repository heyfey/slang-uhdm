module m #(parameter int W = 4)();
  localparam bit EN = (W > 2);
  logic [7:0] arr[2];
  assign arr[0] = (EN) ? 42 : 7;
endmodule
module top;
  m #(.W(1)) u_a();
  m #(.W(8)) u_b();
endmodule
