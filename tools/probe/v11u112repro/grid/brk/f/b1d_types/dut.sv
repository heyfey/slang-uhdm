package pk;
  parameter integer PI = 2;
  parameter bit [3:0] PB = 1;
  parameter byte PY = 1;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
endpackage
module top import pk::*; (input logic [7:0] a, output logic [3:0] y);
  assign y[0] = a[PI-1];
  assign y[1] = a[PB+1];
  assign y[2] = a[PY+2];
  assign y[3] = a[PE+1];
endmodule
