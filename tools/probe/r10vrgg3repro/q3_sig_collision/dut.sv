interface itf #(parameter bit [3:0] AW = 12);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recvA #(parameter int AW = 20)(itf.mp p[3]);
endmodule
module recvB #(parameter logic [7:0] AW = 4)(itf.mp p[3]);
endmodule
module top;
  itf #(9) arr[3]();
  recvA ua (.p(arr));
  recvB ub (.p(arr));
endmodule
