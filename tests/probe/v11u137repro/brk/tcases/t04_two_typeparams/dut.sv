// § defNetTypeParamDefault137
module bottom #(parameter type T = logic, parameter type U = T)(output logic o);
  T a;
  U b;
  assign a = 1'b1;
  assign b = a;
  assign o = b;
endmodule
module top(output logic o);
  bottom u(.o(o));
endmodule
