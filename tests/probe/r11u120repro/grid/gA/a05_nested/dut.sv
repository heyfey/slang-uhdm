module top(output logic [3:0] o);
   typedef struct packed { logic [3:0] d; } in_t;
   typedef struct packed { in_t c; logic e; } out_t;
   out_t a;
   assign a.c.d[1] = 1;
   assign a.c.d[0] = 0;
   assign a.c.d[3:2] = 3;
   assign a.e = 1;
   assign o = a.c.d;
endmodule
