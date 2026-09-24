// § defNetTypeParamDefault137
module bottom #(parameter type TP1 = logic, parameter SIZE = 10);
  TP1 DATA1;
endmodule
module top ();
  bottom #(.TP1(int)) u2();
endmodule
