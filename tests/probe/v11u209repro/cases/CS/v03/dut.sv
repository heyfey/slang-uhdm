// § classTdPkgEnumMemberShares209: a class typedef struct whose member is an enum typedef imported from another package
package q;
  typedef enum { X0, X1 } qe_t;
endpackage
package p;
  import q::*;
  class c;
    typedef struct { qe_t v; int n; } st_t;
    st_t m;
  endclass
endpackage
module top;
endmodule
