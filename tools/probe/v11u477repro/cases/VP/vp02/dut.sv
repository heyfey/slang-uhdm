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
class comp #(type T = obj);
  T exp;
  function void write(T rec);
    if (((exp.compare(rec)))) $display("x");
  endfunction
endclass
module top;
endmodule
