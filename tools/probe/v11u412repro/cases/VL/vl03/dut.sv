// § unitParamBasedLitFold412
parameter A = 1'bx;
parameter B = 1'BX;
parameter logic C = 1'B1;
parameter D = 1'bz;
parameter E = 1'b0;
module top(output logic o);
  assign o = C;
endmodule
