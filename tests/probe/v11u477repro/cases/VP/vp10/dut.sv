// § parenCallWrittenArgs477
class obj;
  function bit compare(obj rhs, obj c = null);
    return 1;
  endfunction
  function int m(int a, int b = 7);
    return a + b;
  endfunction
  static function int sf(int a, int b = 3);
    return a + b;
  endfunction
endclass
module top(output int z);
  initial z = (obj::sf(1));
endmodule
