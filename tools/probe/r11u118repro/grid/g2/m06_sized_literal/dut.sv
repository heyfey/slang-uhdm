module top(output logic [7:0] o);
   struct packed { logic [7:0] b; } a;
   assign a.b[3] = 1'b1;
   assign a.b[2] = 1'b0;
   assign a.b[7:4] = 4'hF;
   assign a.b[1:0] = 2'b10;
   assign o = a.b;
endmodule
