// v97_c5 — HOMES.  The self-typedef shape in a $unit class, a module class, a
// class nested in a class, a class in an interface and a class in a program,
// each parameterized with two live specializations forced by `extends`.
class ucls97c5 #(type T = int);
  typedef ucls97c5 #(T) this_type97c5;
  this_type97c5 nxt;
  T v;
  function void cu(this_type97c5 p); nxt = p; endfunction
endclass
class ui97c5 extends ucls97c5 #(int);
  function void f(this_type97c5 p); nxt = p; endfunction
endclass
class ub97c5 extends ucls97c5 #(byte);
  function void f(this_type97c5 p); nxt = p; endfunction
endclass

class outer97c5;
  class inner97c5 #(type T = int);
    typedef inner97c5 #(T) this_type97c5;
    this_type97c5 nxt;
    T v;
  endclass
endclass

interface if97c5;
  class icls97c5 #(type T = int);
    typedef icls97c5 #(T) this_type97c5;
    this_type97c5 nxt;
    T v;
  endclass
  class ii97c5 extends icls97c5 #(int);
    function void f(this_type97c5 p); nxt = p; endfunction
  endclass
  class ib97c5 extends icls97c5 #(byte);
    function void f(this_type97c5 p); nxt = p; endfunction
  endclass
endinterface

program pg97c5;
  class gcls97c5 #(type T = int);
    typedef gcls97c5 #(T) this_type97c5;
    this_type97c5 nxt;
    T v;
  endclass
  class gi97c5 extends gcls97c5 #(int);
    function void f(this_type97c5 p); nxt = p; endfunction
  endclass
  class gb97c5 extends gcls97c5 #(byte);
    function void f(this_type97c5 p); nxt = p; endfunction
  endclass
endprogram

module top97c5;
  class mcls97c5 #(type T = int);
    typedef mcls97c5 #(T) this_type97c5;
    this_type97c5 nxt;
    T v;
  endclass
  class mi97c5 extends mcls97c5 #(int);
    function void f(this_type97c5 p); nxt = p; endfunction
  endclass
  class mb97c5 extends mcls97c5 #(byte);
    function void f(this_type97c5 p); nxt = p; endfunction
  endclass
endmodule
