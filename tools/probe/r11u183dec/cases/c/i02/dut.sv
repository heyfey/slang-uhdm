interface itf;
  logic a;
  modport mp (input a);
endinterface
module recv #(parameter int N = 3) (
  itf.mp p[0:2]
);
endmodule
module top;
  itf arr[0:2]();
  recv u (.p(arr));
endmodule
