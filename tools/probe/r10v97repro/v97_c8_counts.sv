// v97_c8 — INSTANCE-COUNT sweep: one, two and three live specializations of
// the same self-typedef shape in three sibling generic classes.
package p97c8;
  class one97c8 #(type T = int);
    typedef one97c8 #(T) this_type97c8;
    this_type97c8 nxt;
    T v;
  endclass
  class two97c8 #(type T = int);
    typedef two97c8 #(T) this_type97c8;
    this_type97c8 nxt;
    T v;
  endclass
  class three97c8 #(type T = int);
    typedef three97c8 #(T) this_type97c8;
    this_type97c8 nxt;
    T v;
  endclass
  class o1_97c8 extends one97c8 #(int);
    function void f(this_type97c8 p); nxt = p; endfunction
  endclass
  class t1_97c8 extends two97c8 #(int);
    function void f(this_type97c8 p); nxt = p; endfunction
  endclass
  class t2_97c8 extends two97c8 #(byte);
    function void f(this_type97c8 p); nxt = p; endfunction
  endclass
  class r1_97c8 extends three97c8 #(int);
    function void f(this_type97c8 p); nxt = p; endfunction
  endclass
  class r2_97c8 extends three97c8 #(byte);
    function void f(this_type97c8 p); nxt = p; endfunction
  endclass
  class r3_97c8 extends three97c8 #(shortint);
    function void f(this_type97c8 p); nxt = p; endfunction
  endclass
endpackage
module top97c8;
endmodule
