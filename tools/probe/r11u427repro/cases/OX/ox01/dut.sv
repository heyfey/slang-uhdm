// § oneBitXQuirkTokenOnly427
module top(input logic a, output logic [5:0] y);
  assign y[0] = a & 1'sbx;
  assign y[1] = a | 1'hx;
  assign y[2] = a ^ 1'ox;
  assign y[3] = a & 1'bx;
  assign y[4] = a | 1'Bx;
  assign y[5] = a ^ 1'sbX;
endmodule
