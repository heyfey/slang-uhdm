module top(output logic [7:0] o);
   struct packed { logic [16:0] b; } a;
   assign a.b[7:0] = 8'h5A;
   assign a.b[16:8] = '1;
   assign o = a.b[7:0];
endmodule
