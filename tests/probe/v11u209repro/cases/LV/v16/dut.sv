// § tfItemInitLocalAtType209: a module-scope class handle local initialized from a static call in a paren-less function
class K;
  static function K get(); K k = new; return k; endfunction
endclass
module top;
  function int f;
    K h = K::get();
    return h == null;
  endfunction
  int r;
  initial r = f();
endmodule
