// (r11u191 N0224) a method call nested in the operators of a continued select's index (svaunit_concurrent_assertion_info.svh 133)
class D; int st; function int get_st(); return st; endfunction endclass
class F;
  D q[$];
  function int f();
    return q[q.size() - 1].get_st();
  endfunction
endclass
module top; endmodule
