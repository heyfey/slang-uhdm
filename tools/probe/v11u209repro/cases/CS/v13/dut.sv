// § classTdPkgEnumMemberShares209: a parameterized class with a typedef struct holding a package enum member
package p;
  typedef enum { E0, E1, E2 } e_t;
  class c #(int N = 2);
    typedef struct { e_t v; int n; } st_t;
    st_t m [N];
  endclass
  c #(3) h;
endpackage
module top;
endmodule
