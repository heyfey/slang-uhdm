// § defGenSelBaseLeafAtIndex164 — three-level target, genvar base, literal leaf
module top(output logic [7:0] o);
   typedef struct packed { logic [1:0] f; } in_t;
   typedef struct packed { in_t a; } e_t;
   e_t [3:0] s;
   for (genvar i = 0; i < 4; i++) begin : g
      assign s[i].a.f[0] = 1;
      assign s[i].a.f[1] = 0;
   end
   assign o = s;
endmodule
