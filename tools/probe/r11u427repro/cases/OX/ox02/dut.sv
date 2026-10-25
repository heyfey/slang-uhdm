// § oneBitXQuirkTokenOnly427
module sub #(parameter int Q = 1'sbx, parameter R = 1'hx, parameter logic S = 1'sbx)(output int q);
  assign q = Q;
endmodule
module top(output int q);
  sub u(q);
endmodule
