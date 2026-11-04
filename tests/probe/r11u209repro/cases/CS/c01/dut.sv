// § classTdPkgEnumMemberShares209: a class-scoped struct typedef whose member is a package enum typedef
package p;
  typedef enum {A, B, C} e_t;
  class k;
    typedef struct {
      string s;
      e_t v;
      int i;
    } st_t;
    st_t q[$];
    function void f(output e_t o);
      o = A;
    endfunction
  endclass
endpackage
module top;
endmodule
