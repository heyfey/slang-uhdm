module top(output logic [15:0] o);
   struct packed { logic [7:0] a; logic [7:0] b; } s;
   assign s.a[3:0] = 10;
   assign s.a[7:4] = 4'b1x01;
   assign s.b[7:0] = -8'sd3;
   assign o = s;
endmodule
