// § modParamKwTdCopy250
typedef int ui_t;
module sub #(parameter ui_t W = 1) (output int o);
  assign o = W;
endmodule
module top(output int o1, output int o2);
  sub #(.W(5)) a(.o(o1));
  sub b(.o(o2));
endmodule
