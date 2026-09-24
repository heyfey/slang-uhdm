module top(output logic [7:0] o);
   struct packed { logic [7:0] b; } a;
   assign a.b[3+:2] = 2'b11;
   assign a.b[1:0] = 2'b10;
   assign a.b[7:5] = 3'd5;
   assign o = a.b;
endmodule
