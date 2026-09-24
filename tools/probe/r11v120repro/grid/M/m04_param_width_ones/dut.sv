module sub #(parameter int W = 4) (output logic [15:0] o);
   struct packed { logic [15:0] f; } s;
   assign s.f[W-1:0] = '1;
   assign s.f[15:W] = '0;
   assign o = s.f;
endmodule
module top(output logic [15:0] o1, output logic [15:0] o2);
   sub #(.W(3)) u1(.o(o1));
   sub #(.W(9)) u2(.o(o2));
endmodule
