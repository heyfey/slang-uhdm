// § namedCallArgFormalTs236 — a named call to a class static function from a module continuous assignment, and a named call inside the class method
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
class C;
  static function int sf(p::file_t x, p::byte_t y);
    return x + y;
  endfunction
  static function int g(int z);
    return sf(.y(z), .x(z));
  endfunction
endclass
module top (input int a, input int b, output int o, output int o2);
  assign o = C::sf(.y(b), .x(a));
  assign o2 = C::g(a);
endmodule
