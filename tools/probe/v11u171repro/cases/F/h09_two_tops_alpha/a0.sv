// § tdMoveCarriesFile172
module a0 import pa::*; (input logic [2:0] i, output logic o);
  s_t a [4];
  assign a[0] = i;
  assign o = a[0].y;
endmodule
