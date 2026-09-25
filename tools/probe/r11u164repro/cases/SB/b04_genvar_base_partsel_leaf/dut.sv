// § defGenSelBaseLeafAtIndex164 — gen-for target: a genvar-selected base, a part-selected leaf (control)
module top(output logic [11:0] o);
   typedef struct packed { logic [2:0] f; } e_t;
   e_t [3:0] s;
   for (genvar i = 0; i < 4; i++) begin : g
      assign s[i].f[1:0] = 2'b01;
      assign s[i].f[2] = 1'b0;
   end
   assign o = s;
endmodule
