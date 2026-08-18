module m #(parameter bit P = 0, parameter int Q = 3)();
  logic [7:0] arr[2];
  assign arr[0] = (Q inside {1,2,3}) ? 42 : 7;
endmodule
module top;
  m #(.Q(9)) u_a();
endmodule
