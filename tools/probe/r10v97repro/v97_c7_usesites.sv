// v97_c7 — the self typedef of a parameterized class exercised at every use
// site: property, static property, local property, return type, formal, local
// variable, cast, new(), a #(this_type) parameter, a derived class, a static
// method, a virtual method and an extern/OOB body.
package p97c7;
  class holder97c7 #(type H = int);
    H h;
  endclass
  class base97c7 #(type T = int);
    typedef base97c7 #(T) this_type97c7;
    this_type97c7        p_prop;
    static this_type97c7 s_prop;
    local this_type97c7  l_prop;
    T v;
    function this_type97c7 f_ret();
      this_type97c7 loc;
      loc = this_type97c7'(p_prop);
      loc = new();
      l_prop = loc;
      return loc;
    endfunction
    function void f_arg(this_type97c7 a); p_prop = a; endfunction
    static function this_type97c7 f_static(); return s_prop; endfunction
    virtual function this_type97c7 f_virt(); return p_prop; endfunction
    extern function this_type97c7 f_oob(this_type97c7 z);
  endclass
  function base97c7::this_type97c7 base97c7::f_oob(this_type97c7 z);
    return z;
  endfunction
  class di97c7 extends base97c7 #(int);
    function void f(this_type97c7 p); p_prop = p; endfunction
  endclass
  class db97c7 extends base97c7 #(byte);
    holder97c7 #(this_type97c7) hh;
    function void f(this_type97c7 p); p_prop = p; endfunction
  endclass
endpackage
module top97c7;
endmodule
