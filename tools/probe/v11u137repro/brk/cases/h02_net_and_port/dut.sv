// § defNetTypeParamDefault137
module bottom #(parameter type TP1 = logic)(input TP1 i, output TP1 o);
  TP1 t;
  assign t = i;
  assign o = t;
endmodule
module top (input logic a, output logic b);
  bottom u(.i(a), .o(b));
endmodule
