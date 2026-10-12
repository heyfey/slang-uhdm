// § dynAssocMemberSpanToDim295
package p;
  typedef struct { int m[string]; } s_t;
  class c;
    s_t s;
  endclass
endpackage
module top(output logic o);
  import p::*;
  assign o = 1'b0;
endmodule
