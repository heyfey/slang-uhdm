// § parenCallCallee479
class Maker;
  int v;
  static function Maker mk(); Maker m = new; return m; endfunction
  function int rd(int a); return a + v; endfunction
endclass
module top(output int z);
  initial z = (Maker::mk().rd(7));
endmodule
