// § defNetTypeParamDefault137
module bottom #(parameter type T = logic [7:0])(output logic o);
  T d;
  assign o = d[0];
endmodule
module top (output logic o1, o2);
  bottom u1(.o(o1));
  bottom #(.T(logic [3:0])) u2(.o(o2));
endmodule
