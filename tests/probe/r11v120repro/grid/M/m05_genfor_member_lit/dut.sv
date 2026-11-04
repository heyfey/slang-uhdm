module top(output logic [7:0] o);
   typedef struct packed { logic [1:0] f; } e_t;
   e_t [3:0] s;
   for (genvar i = 0; i < 4; i++) begin : g
      assign s[i].f[0] = 1;
      assign s[i].f[1] = 0;
   end
   assign o = s;
endmodule
