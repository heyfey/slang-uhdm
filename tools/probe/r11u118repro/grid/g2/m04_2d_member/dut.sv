module top(output logic [2:0] o);
   typedef struct packed { logic [2:0] x; } struct_t;
   struct_t [1:0][2:0] a;
   assign a[0][0].x[2] = 1;
   assign a[0][0].x[1:0] = 2'b01;
   assign o = a[0][0].x;
endmodule
