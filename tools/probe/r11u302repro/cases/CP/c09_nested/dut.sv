// § castPatTagKeyLocThroughParens302
// c09: a nested struct with an inner cast-wrapped pattern
package p;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
  localparam c_t C = c_t'('{u: in_t'('{x: 1, y: 2}), d: 3});
endpackage
module dut (output logic [7:0] o);
  assign o = p::C.u.x;
endmodule
