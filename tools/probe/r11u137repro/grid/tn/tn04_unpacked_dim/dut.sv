// § defNetTypeParamDefault137
module bottom #(parameter type TP1 = logic);
  TP1 DATA1 [3:0];
endmodule
module top ();
  bottom #(.TP1(int)) u2();
endmodule
