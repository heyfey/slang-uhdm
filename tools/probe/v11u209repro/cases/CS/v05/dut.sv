// § classTdPkgEnumMemberShares209: a class declared in a module with a typedef struct holding a package enum member
package p;
  typedef enum { M0, M1 } e_t;
endpackage
module top;
  class c;
    typedef struct { p::e_t v; int n; } st_t;
    st_t m;
  endclass
  c h;
endmodule
