// face-1 enum-leaf measure: enum with unsized init + a sized literal operand
package q2;
  typedef enum logic [5:0] {EA = 3, EB = 60} e_t;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {EA, 6'h1}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
