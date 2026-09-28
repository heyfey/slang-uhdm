// § classTdPkgEnumMemberShares209 — r11u217 c02: a class-scope union typedef with a package enum member, an enum typedef from ANOTHER package through a wildcard import, and a class-scope enum typedef member (declined by the law)
package ep;
  typedef enum logic [1:0] { X, Y } f_t;
endpackage
package p;
  import ep::*;
  typedef enum logic [1:0] { A, B } e_t;
  class k;
    typedef enum logic [1:0] { L, M } ce_t;
    typedef union packed { e_t a; f_t b; } u_t;
    typedef struct packed { f_t x; ce_t y; } s_t;
    u_t u;
    s_t s;
  endclass
endpackage
module top;
  p::k h;
endmodule
