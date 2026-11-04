// § parenCallWrittenArgs477
class obj;
  static function int sf(int a, int b = 2, int c = 3);
    return a;
  endfunction
  function bit compare(obj rhs, obj c = null, int k = 7);
    return 1;
  endfunction
endclass
class comp;
  obj exp;
  int b;
  function void write(obj rec);
    b = (obj::sf(1)) + (obj::sf(1, 5));
  endfunction
endclass
module top;
endmodule
