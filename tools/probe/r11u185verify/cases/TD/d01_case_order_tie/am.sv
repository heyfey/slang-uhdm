// § tdEndMoveModuleOrder176
module am import pa::*; (input logic [3:0] i, output logic o);
  s_t a [3];
  assign a[0] = i;
  assign o = a[0].y;
endmodule
