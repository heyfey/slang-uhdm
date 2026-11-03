// § parenCallCallee479
class obj;
  static function int sf(int a, int b = 3);
    return a + b;
  endfunction
endclass
module top(output int z);
  initial z = obj::sf(1);
endmodule
