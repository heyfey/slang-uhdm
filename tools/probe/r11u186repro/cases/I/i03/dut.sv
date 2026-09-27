// § ifaceArrPortSizeDimAtExpr183 (control: the range form keeps the bracket)
interface itf;
  logic a;
endinterface
module recv (itf p[0:2]);
endmodule
module top;
  itf arr[0:2]();
  recv u (.p(arr));
endmodule
