module top(output logic [7:0] o);
   struct packed { logic [7:0] b; logic c; } a;
   assign a.b = 8'h3C;
   assign a.c = 1;
   assign o = a.b;
endmodule
