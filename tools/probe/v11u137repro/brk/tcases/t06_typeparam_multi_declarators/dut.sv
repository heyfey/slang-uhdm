// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(output logic o);
  T a, b [2], c;
  assign a = 1'b1;
  assign o = a;
endmodule
module top(output logic o);
  bottom #(.T(bit)) u(.o(o));
endmodule
