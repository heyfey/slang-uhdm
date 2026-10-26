// § unitNameBindNotInClass431v (a class property initializer in a module class)
localparam CF = 2;
module top(output int y);
localparam CF = 1;
class C;
  int x = CF;
endclass
initial begin C o = new; y = o.x; end
endmodule
