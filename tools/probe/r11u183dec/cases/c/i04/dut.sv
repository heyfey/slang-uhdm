interface itf;
  logic a;
  modport mp (input a);
endinterface
module recv #(parameter int N = 3) (
  itf.mp p[N-1:0]
);
endmodule
module top;
  itf arr[3]();
  recv u (.p(arr));
endmodule
