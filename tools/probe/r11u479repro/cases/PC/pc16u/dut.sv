// § parenCallCallee479 (control: the unparenthesized twin of pc16)
class obj;
  static function int sf(int a); return a; endfunction
endclass
package q;
  function automatic int g(); return obj::sf(2); endfunction
endpackage
module top; endmodule
