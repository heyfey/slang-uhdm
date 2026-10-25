// § oneBitXQuirkTokenOnly427
module top(input logic [1:0] a, output logic y, output logic z);
  assign y = 1'dx;
  assign z = (a == 2'b01) ? 1'hX : 1'sbz;
endmodule
