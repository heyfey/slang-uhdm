// § vlogAggMemberKwSpan237
// a package struct with bit and logic members
package p;
  typedef struct packed { bit [3:0] a; logic [7:0] b; } s_t;
endpackage
module top(output [11:0] o);
  p::s_t x;
  assign o = x;
endmodule
