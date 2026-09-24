module top(output logic [7:0] o);
   union packed { logic [7:0] x; logic [7:0] y; } u;
   assign u.x[0] = 1;
   assign u.x[7:1] = 7'h55;
   assign o = u.y;
endmodule
