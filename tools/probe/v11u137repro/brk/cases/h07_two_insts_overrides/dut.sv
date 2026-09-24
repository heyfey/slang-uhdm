// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(output logic o);
  T d;
  assign d = '1;
  assign o = d[0];
endmodule
module top (output logic o1, o2, o3);
  bottom #(.T(int)) u1(.o(o1));
  bottom #(.T(byte)) u2(.o(o2));
  bottom u3(.o(o3));
endmodule
