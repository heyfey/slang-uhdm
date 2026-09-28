`include "defs.svh"
package p;
  parameter int W = 4;
  parameter int N = W == 4 ? `LEAF : 1;
  parameter int M = `PICK(W == 4, W + 1, 0);
endpackage
