// § defGenSelBaseLeafAtIndex164 — nested genvars, base and leaf each selected by a genvar
module top(output logic [7:0] o);
   typedef struct packed { logic [1:0] f; } e_t;
   e_t [3:0] s;
   for (genvar i = 0; i < 4; i++) begin : g
      for (genvar j = 0; j < 2; j++) begin : h
         assign s[i].f[j] = 1;
      end
   end
   assign o = s;
endmodule
