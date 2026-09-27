// § ifaceArrPortSizeDimAtExpr183 (positional connection)
interface itf;
  logic a;
  modport mp (output a);
endinterface
module recv (itf.mp p [ 3 ]);
endmodule
module top;
  itf arr[3]();
  recv u (arr);
endmodule
