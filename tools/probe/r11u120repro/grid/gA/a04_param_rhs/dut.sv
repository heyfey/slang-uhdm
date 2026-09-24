module top #(parameter int P = 1) (output logic [7:0] o);
   struct packed { logic [7:0] b; } a;
   assign a.b[0] = P;
   assign a.b[7:1] = '1;
   assign o = a.b;
endmodule
