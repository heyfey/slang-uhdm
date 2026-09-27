interface itf;
  logic a;
  modport mp (input a);
endinterface
module recv #(parameter int N = 3) (
  itf.mp p[2:0]
);
endmodule
module top;
  itf arr[2:0]();
  recv u (.p(arr));
endmodule
