// § unitNameBindNotInClass431v (a static class method reading a module localparam, class in a package-free module)
localparam CF = 2, XF = 3;
module top(output int y, output int z);
localparam CF = 1;
class C;
  static function int f(); return CF + XF; endfunction
endclass
initial begin y = C::f(); z = CF; end
endmodule
