// § defGenSelBaseLeafAtIndex164 — gen-for target: a genvar-selected base, a plain leaf (control)
module top(output logic [7:0] o);
   typedef struct packed { logic [1:0] f; } e_t;
   e_t [3:0] s;
   for (genvar i = 0; i < 4; i++) begin : g
      assign s[i].f = 2'b01;
   end
   assign o = s;
endmodule
