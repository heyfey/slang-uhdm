module top(output logic [7:0] o);
   struct packed { logic [16:0] b; } a;
   assign a.b[0] = 1;
   assign a.b[16:1] = '0;
   assign o = a.b[7:0];
endmodule
