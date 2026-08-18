module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? 42 : 0 : 1 : 2 : 3 : 4 : 5 : 6 : 7 : 8 : 9 : 10 : 11 : 12 : 13 : 14 : 15 : 16 : 17 : 18 : 19 : 20 : 21 : 22 : 23 : 24 : 25 : 26 : 27 : 28 : 29 : 30 : 31 : 32 : 33;
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
