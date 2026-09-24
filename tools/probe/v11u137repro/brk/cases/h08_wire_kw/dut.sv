// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(output logic o);
  wire T w;
  assign w = 1'b1;
  assign o = w;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
