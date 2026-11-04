// D2: a control: the cast alone (no evalFunc stamps: the two typedefs read
// the same either way).
package p;
  typedef struct packed { logic [7:0] A; logic B; } cfg_t;
  localparam cfg_t E = cfg_t'(0);
endpackage
module top #(parameter p::cfg_t C = p::E) (output logic o);
  assign o = C.B;
endmodule
