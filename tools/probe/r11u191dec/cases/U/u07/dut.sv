// (r11u191) a module-local sized hex parameter and a local unsized one, both read into a 32-bit LHS
module m(output int a, output int b);
   localparam logic [15:0] X = 16'h12;
   localparam logic [7:0] Y = 5;
   assign a = X;
   assign b = Y;
endmodule
module top(output int o, output int q);
   m u(.a(o), .b(q));
endmodule
