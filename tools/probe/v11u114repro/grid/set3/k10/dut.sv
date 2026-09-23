// verifier: enum init unsized arithmetic
package q2;
  typedef enum logic [5:0] {EA = 1 + 2, EB = 6'd60} e_t;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {EA, EB}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
