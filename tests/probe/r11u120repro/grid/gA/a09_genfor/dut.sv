module top(output logic [7:0] o);
   struct packed { logic [7:0] b; } a;
   for (genvar i = 0; i < 4; i++) begin : g
      assign a.b[i] = 1;
   end
   assign a.b[7:4] = 4'h9;
   assign o = a.b;
endmodule
