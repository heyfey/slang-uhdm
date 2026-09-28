// § classTdPkgEnumMemberShares209: a class typedef union and struct with package enum members, the enum also a method formal
package p;
  typedef enum logic [2:0] { R0, R1, R2 } e_t;
  class c;
    typedef struct packed { e_t a; logic b; } ps_t;
    typedef union packed { e_t u; logic [2:0] w; } pu_t;
    ps_t s;
    pu_t v;
    function void set(e_t z); s.a = z; endfunction
  endclass
endpackage
module top;
endmodule
