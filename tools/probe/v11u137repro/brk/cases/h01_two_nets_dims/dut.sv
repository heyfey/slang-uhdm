// § defNetTypeParamDefault137
module bottom #(parameter type TP1 = logic);
  TP1 A [3:0];
  TP1 B [1:0];
endmodule
module top ();
  bottom #(.TP1(int)) u2();
endmodule
