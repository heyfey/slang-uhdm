// § defNetTypeParamDefault137
module bottom #(parameter type TP1 = logic);
  TP1 DATA1;
endmodule
module top ();
  bottom u2();
endmodule
