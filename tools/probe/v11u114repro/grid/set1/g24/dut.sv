// face-1 break: pattern member whose value is a CONCAT of a pattern-typed struct param member select
package q2;
  typedef struct packed { logic [3:0] a; logic [7:0] v; } e_t;
  localparam e_t B = '{a: 4'h1, v: 8'h22};
  localparam e_t C = '{a: 4'h1, v: {B.a, 4'h3}};
endpackage
module top(output logic [7:0] o); assign o = q2::C.v; endmodule
