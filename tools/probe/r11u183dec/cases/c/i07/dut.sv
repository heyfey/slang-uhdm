interface itf;
  logic a;
endinterface
module recv (
  itf p[3]
);
endmodule
module top;
  itf arr[3]();
  recv u (.p(arr));
endmodule
