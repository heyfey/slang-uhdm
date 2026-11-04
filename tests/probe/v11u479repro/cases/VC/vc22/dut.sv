// § parenCallCallee479
package p;
  class C; static function int sf(int a); return a; endfunction endclass
  class D; function int g(); return (C::sf(5)); endfunction endclass
endpackage
module top; import p::*; D d; endmodule
