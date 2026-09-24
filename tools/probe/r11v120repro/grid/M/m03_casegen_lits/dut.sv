module sub #(parameter int K = 0) (output logic [3:0] o);
   struct packed { logic [3:0] f; } s;
   case (K)
     0: begin : c0 assign s.f[1:0] = 1; end
     1: begin : c1 assign s.f[1:0] = 2; end
     default: begin : cd assign s.f[1:0] = 3; end
   endcase
   assign s.f[3:2] = 2;
   assign o = s.f;
endmodule
module top(output logic [3:0] o0, output logic [3:0] o1, output logic [3:0] o2);
   sub #(.K(0)) u0(.o(o0));
   sub #(.K(1)) u1(.o(o1));
   sub #(.K(5)) u2(.o(o2));
endmodule
