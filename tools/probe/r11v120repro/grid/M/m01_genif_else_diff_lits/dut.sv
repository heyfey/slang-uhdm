module sub #(parameter bit P = 1) (output logic [7:0] o);
   struct packed { logic [7:0] b; } s;
   if (P) begin : g1
      assign s.b[0] = 1;
   end else begin : g0
      assign s.b[0] = 0;
   end
   assign s.b[3:1] = 5;
   assign s.b[7:4] = '0;
   assign o = s.b;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2);
   sub #(.P(1)) u1(.o(o1));
   sub #(.P(0)) u2(.o(o2));
endmodule
