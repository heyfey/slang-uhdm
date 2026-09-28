// § classTdPkgEnumMemberShares209: a class typedef struct whose members are a class-scope enum and a package enum
package p;
  typedef enum { E0, E1 } e_t;
  class c;
    typedef enum { L0, L1 } le_t;
    typedef struct { le_t l; e_t v; } st_t;
    st_t m;
  endclass
endpackage
module top;
endmodule
