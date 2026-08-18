module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];
  localparam logic [7:0] AP [2] = '{8'd3, 8'd9};

  assign arr[0] = (P) ? AP[1] : 7;
endmodule
module top;
  m u_a();
endmodule
