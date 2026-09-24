// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(output logic o);
  T a [3:0];
  T b;
  assign b = 1'b1;
  assign o = b;
endmodule
module top(output logic o);
  bottom u(.o(o));
endmodule
