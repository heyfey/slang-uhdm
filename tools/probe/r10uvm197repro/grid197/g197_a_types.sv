package tPkg;
  typedef logic [3:0] nib_t;
  typedef string      str_t;
  parameter string    P_STR   = "hello";
  parameter str_t     P_TSTR  = "tdef";
  parameter           P_USTR  = "untyped";
  parameter int       P_INT   = 7;
  parameter integer   P_ITG   = 9;
  parameter byte      P_BYTE  = 8'd3;
  parameter logic [7:0] P_VEC = 8'hAB;
  parameter nib_t     P_TNIB  = 4'h5;
  parameter real      P_REAL  = 1.5;
  parameter shortreal P_SREAL = 2.5;
  parameter bit       P_BIT   = 1'b1;
  parameter [5:0]     P_RANGE = 6'd12;
  parameter time      P_TIME  = 3ns;
endpackage
import tPkg::*;
module tTop;
  initial $display(P_STR);
endmodule
