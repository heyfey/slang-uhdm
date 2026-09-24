module top #(parameter bit EN = 1) (output logic [7:0] o);
   struct packed { logic [16:0] b; } a;
   if (EN) begin : g
      assign a.b[0] = 1;
   end
   assign a.b[16:1] = '0;
   assign o = a.b[7:0];
endmodule
