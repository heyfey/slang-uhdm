// § patternCaseNoItems403
module top;
  typedef union tagged { bit [3:0] a; void n; } u;
  u x; int y;
  initial unique casex (x) matches tagged a 4'b1x0?: y = 1; default: y = 0; endcase
endmodule
