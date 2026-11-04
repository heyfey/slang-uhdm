// § parenCallCallee479
package p;
  class C; static function int sf(int a); return a; endfunction endclass
endpackage
module top(output int z); initial z = (p::C::sf(1)); endmodule
