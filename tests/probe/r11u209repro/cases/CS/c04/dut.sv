// § classTdPkgEnumMemberShares209: a class-scoped struct typedef with a package enum member, no formal writer
package p;
  typedef enum {A, B, C} e_t;
  class k;
    typedef struct {
      string s;
      e_t v;
    } st_t;
    st_t q[$];
  endclass
endpackage
module top;
endmodule
