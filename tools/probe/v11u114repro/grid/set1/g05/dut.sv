// face-1 break: enum leaf with int-based enum (32 bits) truncated? concat width 12 via 2x6 no: use a 6-bit enum w/o base
package q2;
  typedef enum bit [5:0] {EA, EB} e_t;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {EA, EB}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
