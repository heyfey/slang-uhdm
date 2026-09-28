// § classTdPkgEnumMemberShares209: a class-scoped packed struct typedef with a package enum member
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class k;
    typedef struct packed {
      logic s;
      e_t v;
    } st_t;
    st_t q;
  endclass
endpackage
module top;
endmodule
