// § defNetTypeParamDefault137
module bottom #(parameter type TP1 = logic [7:0]);
  TP1 d = '1;
endmodule
module top ();
  bottom #(.TP1(int)) u2();
endmodule
