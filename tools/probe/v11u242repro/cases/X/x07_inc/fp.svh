`define PICK(x) (x)
package fp;
  parameter int WM = 2;
  parameter int LB = 3;
  parameter int W = WM == 1 ? 1 : `PICK(LB);
  parameter int Z = WM == 2 ? LB + 1 : 1;
endpackage
