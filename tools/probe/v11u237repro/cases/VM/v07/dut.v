// § vlogAggMemberKwSpan237
// an unpacked struct in a function formal and a union of struct members in a package
package p;
  typedef struct packed { logic [3:0] a; } s_t;
  typedef union packed { s_t s; bit [3:0] b; } u_t;
endpackage
module top(input [3:0] i, output [3:0] o);
  p::u_t x;
  assign x.b = i;
  assign o = x.s.a;
endmodule
