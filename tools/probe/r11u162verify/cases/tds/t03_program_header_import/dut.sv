// § tdStretchProgramKeeps155v
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
program p import pk::*; ();
  s_t x [2];
  initial x[1] = 0;
endprogram
