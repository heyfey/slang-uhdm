// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(output logic o);
  T b;
  T a [1:0][3:0];
  assign b = 1'b1;
  assign o = b;
endmodule
module top(output logic o);
  bottom u(.o(o));
endmodule
