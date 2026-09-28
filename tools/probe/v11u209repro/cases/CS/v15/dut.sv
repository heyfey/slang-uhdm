// § classTdPkgEnumMemberShares209: a package-qualified enum member in a class typedef struct, the enum a formal of a package function
package q;
  typedef enum logic [1:0] { Q0, Q1 } qe_t;
  function automatic int conv(qe_t z); return int'(z); endfunction
endpackage
package p;
  class c;
    typedef struct packed { q::qe_t v; logic b; } st_t;
    st_t m;
  endclass
endpackage
module top;
endmodule
