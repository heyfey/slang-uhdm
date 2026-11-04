// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(input T i, output logic o);
  T d [3:0];
  assign d[0] = i;
  assign o = d[0];
endmodule
module top(input logic a, output logic b);
  bottom u(.i(a), .o(b));
endmodule
