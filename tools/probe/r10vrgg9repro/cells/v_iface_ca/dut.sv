interface bif #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : 7;
endinterface
module top;
  bif #(.P(1)) bi();
endmodule
