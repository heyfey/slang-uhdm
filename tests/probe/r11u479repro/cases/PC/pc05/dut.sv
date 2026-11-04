// § parenCallCallee479
class obj;
  static function int sf(int a);
    return a;
  endfunction
endclass
module top(output int z);
  initial z = (obj::sf(1));
endmodule
