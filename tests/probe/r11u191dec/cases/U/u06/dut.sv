// (r11u191) control: a module-local parameter with the same defaults (not a package parameter)
module m(output logic [7:0] a, output int b);
   localparam logic [15:0] X = 16'h12;
   localparam logic [7:0] Y = 5;
   assign a = X;
   assign b = Y;
endmodule
module top(output logic [7:0] o, output int q);
   m u(.a(o), .b(q));
endmodule
