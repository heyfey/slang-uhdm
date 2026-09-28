// § anonMemberTdLastWriter212 — package struct typedefs: an outer package struct whose member is written with the inner package typedef
package p;
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  typedef struct packed { in_t x; logic c; } out_t;
endpackage
module dut(input logic [5:0] d, output logic o);
  p::out_t v;
  assign v = d;
  assign o = v.x.b;
endmodule
