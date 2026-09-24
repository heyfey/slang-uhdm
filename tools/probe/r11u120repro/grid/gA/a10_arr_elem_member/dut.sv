module top(output logic [3:0] o);
   typedef struct packed { logic [3:0] x; } s_t;
   s_t [1:0] a;
   assign a[1].x[0] = 1;
   assign a[1].x[3:1] = 3'b010;
   assign a[0] = '0;
   assign o = a[1].x;
endmodule
