module m #(parameter int W = 4) (output logic [7:0] o);
   struct packed { logic [7:0] b; } a;
   assign a.b[W-1:0] = 3;
   assign a.b[7:W] = '0;
   assign o = a.b;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2);
   m #(.W(2)) u1(.o(o1));
   m #(.W(6)) u2(.o(o2));
endmodule
