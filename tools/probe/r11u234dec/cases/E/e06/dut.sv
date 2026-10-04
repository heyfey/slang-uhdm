// § decode E: the only formal written T is an extern prototype's (its out-of-body body is not a writer)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static T m;
    extern function void g(T b);
  endclass
  function void W::g(T b); endfunction
endpackage
