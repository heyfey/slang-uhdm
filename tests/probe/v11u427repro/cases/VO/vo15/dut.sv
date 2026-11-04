// § oneBitXQuirkTokenOnly427
module top(input [1:0] s, output logic o);
  always_comb case (s) 2'b00: o = 1'ox; default: o = 1'sbX; endcase
endmodule
