// § parenCallCallee479
class gen #(type T = int);
  static function int gf(int a); return a; endfunction
endclass
module top(output int z);
  initial z = (gen#(int)::gf(3));
endmodule
