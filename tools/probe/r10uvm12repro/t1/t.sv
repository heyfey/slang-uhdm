package p;
  class sub;
    static function int getv(int a);
      return a + 1;
    endfunction
    static task settv(int a);
    endtask
    function int inst_f(int a);
      return a;
    endfunction
  endclass
  class user;
    int r;
    task go();
      sub::settv(4);
      r = sub::getv(3);
      void'(sub::getv(5));
    endtask
  endclass
  function int pkgf();
    return sub::getv(7);
  endfunction
endpackage

module top;
  import p::*;
  int z;
  initial begin
    z = sub::getv(9);
  end
endmodule
