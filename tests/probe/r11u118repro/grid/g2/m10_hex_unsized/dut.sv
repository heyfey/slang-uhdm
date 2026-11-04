module top(output logic [7:0] o);
   struct packed { logic [15:0] b; } a;
   assign a.b[7:0] = 'hA5;
   assign a.b[15:8] = 'd3;
   assign o = a.b[7:0];
endmodule
