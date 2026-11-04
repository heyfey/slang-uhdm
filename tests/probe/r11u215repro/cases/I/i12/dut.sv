// § impPatCopyFirstListingUnparented215 — control: a nested struct pattern (the copy's head carries no typespec: impNestedPat9)
package hp;
  typedef struct packed { logic a; logic [2:0] c; } in_t;
  typedef struct packed { in_t s; logic b; } n_t;
  parameter n_t NA = '{ s: '{ a: 1'b1, c: 3'd5 }, b: 1'b0 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module dut import ip::*; (output logic [4:0] o);
  assign o = LOC;
endmodule
