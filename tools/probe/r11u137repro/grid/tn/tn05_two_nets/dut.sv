// § defNetTypeParamDefault137
module bottom #(parameter type TP1 = logic [3:0]);
  TP1 a;
  TP1 b;
endmodule
module top ();
  bottom #(.TP1(byte)) u1();
  bottom u2();
endmodule
