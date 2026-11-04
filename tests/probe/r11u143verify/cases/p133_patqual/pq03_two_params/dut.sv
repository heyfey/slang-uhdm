// § elabPatQualRefQualSpan133
// case pq03: two pattern parameters in one list, both qualified defaults
package tp;
  typedef struct packed { int unsigned X; int unsigned Y; } s_t;
  localparam s_t One = '{X: 1, Y: 2};
  localparam s_t Two = '{X: 3, Y: 4};
endpackage
module dut #(parameter tp::s_t A = tp::One, parameter tp::s_t B = tp::Two) (output logic [31:0] o);
  assign o = A.X + B.Y;
endmodule
