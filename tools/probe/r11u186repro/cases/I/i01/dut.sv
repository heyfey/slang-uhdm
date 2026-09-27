// § ifaceArrPortSizeDimAtExpr183
interface itf;
  logic a;
  modport mp (input a);
endinterface
module recv #(parameter int N = 2) (itf.mp p[N]);
endmodule
module top;
  itf arr[2]();
  recv #(.N(2)) u (.p(arr));
endmodule
