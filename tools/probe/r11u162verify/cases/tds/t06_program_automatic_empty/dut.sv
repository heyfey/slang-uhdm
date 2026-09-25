// § tdStretchProgramKeeps155v
package pk; typedef struct packed { logic [1:0] a; } s_t; endpackage
program automatic p();
  import pk::*;
  s_t x [3];
  initial x[2] = 2'b01;
endprogram
