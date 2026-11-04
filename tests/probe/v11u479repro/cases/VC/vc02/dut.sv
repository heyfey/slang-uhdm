// § parenCallCallee479
class Outer;
  class Inner; static function int sf(int a); return a; endfunction endclass
endclass
module top(output int z); initial z = (Outer::Inner::sf(1)); endmodule
