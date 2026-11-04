// § modFnLitLeftoverAtLiteral302
// l13: the builder body comes from an included file
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  `include "body.svh"
  localparam pk::c_t L = mk();
  localparam int unsigned LA = L.b;
  assign o = 1'b0;
endmodule
