// § classTdStructMemberPkgPath146
package p;
  class c;
    typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
    typedef union packed { s_t s; logic [7:0] w; } u_t;
    u_t v;
  endclass
endpackage
module top; endmodule
