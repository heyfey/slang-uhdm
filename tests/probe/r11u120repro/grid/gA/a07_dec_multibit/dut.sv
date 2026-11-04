module top(output logic [7:0] o);
   struct packed { logic [7:0] b; } a;
   assign a.b[3:0] = 5;
   assign a.b[7:4] = 10;
   assign o = a.b;
endmodule
