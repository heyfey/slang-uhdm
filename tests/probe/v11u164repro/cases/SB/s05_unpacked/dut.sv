// § defGenSelBaseLeafAtIndex164 — an unpacked array of structs, genvar base, literal leaf
module top(output logic [1:0] o);
   typedef struct packed { logic [1:0] f; } e_t;
   e_t s [4];
   for (genvar i = 0; i < 4; i++) begin : g
      assign s[i].f[0] = 1;
      assign s[i].f[1] = 0;
   end
   assign o = s[0].f;
endmodule
