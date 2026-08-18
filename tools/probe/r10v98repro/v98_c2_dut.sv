// v98_c2 — H1 variants: the winner declares the racing name with an ENUM /
// STRUCT / UNPACKED-ARRAY / forward-declared target.
package q98v;
  class a1cls98v;
    typedef enum bit [1:0] { E0, E1 } ek_t;
    typedef struct packed { bit a; bit b; } sk_t;
    typedef int uk_t [3];
    typedef bit [15:0] fk_t;
  endclass
  class m1base98v;
    typedef int   ek_t;
    typedef int   sk_t;
    typedef int   uk_t;
    typedef int   fk_t;
    function void ob(ek_t a, sk_t b); endfunction
  endclass
  class z1der98v extends m1base98v;
    function void hot(ek_t a, sk_t b, fk_t d); endfunction
    function void hotu(uk_t c); endfunction
  endclass
endpackage
module top98v2;
  import q98v::*;
  z1der98v z;
  initial z = new();
endmodule
