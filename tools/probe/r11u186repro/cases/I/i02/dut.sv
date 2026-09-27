// § ifaceArrPortSizeDimAtExpr183 (plain interface port, arithmetic size)
interface itf;
  logic a;
endinterface
module recv (itf p[2*2]);
endmodule
module top;
  itf arr[4]();
  recv u (.p(arr));
endmodule
