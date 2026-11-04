module top(input logic a, output logic [7:0] o, output logic w2);
   wire w1 = 0;
   assign w2 = a;
   struct packed { logic [7:0] b; } s;
   assign s.b[0] = 1;
   assign s.b[2:1] = 2;
   assign s.b[7:3] = 9;
   assign o = s.b | {7'b0, w1};
endmodule
