module top(output logic [7:0] o);
   struct packed { logic [16:0] b; } a;
   assign a.b[0 +: 8] = 8'hA5;
   assign a.b[16:8] = '0;
   assign o = a.b[0+:8];
endmodule
