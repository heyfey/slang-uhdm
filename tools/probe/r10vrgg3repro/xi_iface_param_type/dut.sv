interface itf #(parameter type T = logic [15:0]);
  T a;
  modport mp (input a);
endinterface
module recv #(parameter type T = logic [4:0])(itf.mp p[3]);
endmodule
module top;
  itf #(logic [7:0]) arr[3]();
  recv u (.p(arr));
endmodule
