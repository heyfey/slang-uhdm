// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(output logic o);
  T d = 1'b1;
  var T v;
  assign v = d;
  assign o = v;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
