// § classTdPkgEnumMemberShares209: a package-scope struct typedef with a package enum member (control)
package p;
  typedef enum {A, B, C} e_t;
  typedef struct {
    string s;
    e_t v;
  } st_t;
  class k;
    st_t q[$];
  endclass
endpackage
module top;
endmodule
