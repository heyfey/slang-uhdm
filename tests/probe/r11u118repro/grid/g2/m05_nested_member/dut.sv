module top(output logic [3:0] o);
   typedef struct packed { logic [3:0] y; } in_t;
   struct packed { in_t i; logic [3:0] z; } a;
   assign a.i.y[3] = 1'b1;
   assign a.i.y[2:0] = 3'd5;
   assign a.z = '0;
   assign o = a.i.y;
endmodule
