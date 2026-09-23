// face-1 enum-leaf measure: unsized first, auto second; read auto twice
package q2;
  typedef enum logic [5:0] {EA = 3, EB} e_t;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {EB, EB}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
