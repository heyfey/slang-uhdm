module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];

  assign arr[0] = (P) ? int'($ceil(3.2)) : 7;
endmodule
module top;
  m u_a();
endmodule
