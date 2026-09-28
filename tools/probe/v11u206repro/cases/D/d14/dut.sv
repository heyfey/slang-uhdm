// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
    typedef enum {E0, E1} e_t;
    typedef struct packed { logic a; } s_t;
  endclass
  class D;
    function K::e_t g();
      return K::E0;
    endfunction
  endclass
endpackage
module d14; endmodule
