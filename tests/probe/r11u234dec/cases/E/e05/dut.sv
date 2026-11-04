// § decode E: two formals written T, an in-body method then an extern prototype (the later writes last)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
    extern function void g(input T b);
  endclass
  function void W::g(input T b); endfunction
endpackage
