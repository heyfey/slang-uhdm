// § dynAssocMemberSpanToDim295
package p;
  typedef struct {
    int m[string];
    logic [3:0] n[int];
  } s_t;
endpackage
module top(output logic o);
  p::s_t s;
  assign o = 1'b0;
endmodule
