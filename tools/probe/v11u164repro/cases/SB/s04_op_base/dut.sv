// § defGenSelBaseLeafAtIndex164 — an operation base index (control: the law abstains)
module top(output logic [7:0] o);
   typedef struct packed { logic [1:0] f; } e_t;
   e_t [3:0] s;
   for (genvar i = 0; i < 3; i++) begin : g
      assign s[i+1].f[0] = 1;
      assign s[i+1].f[1] = 0;
   end
   assign s[0] = '0;
   assign o = s;
endmodule
