// § classTdPkgEnumMemberShares209: a nested struct inside a class typedef struct with a package enum member
package p;
  typedef enum { N0, N1 } e_t;
  class c;
    typedef struct { struct { e_t e; int i; } in; int o; } st_t;
    st_t m;
  endclass
endpackage
module top;
endmodule
