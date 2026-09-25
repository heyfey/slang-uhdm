// § memberEnumCloneKeepsBase147
// case f04: control, B types the member with the SCOPED name A::e (no import clone)
package ea4;
  typedef enum logic [1:0] {P0 = 2'd0, P1 = 2'd1} ph_e;
endpackage
package eb4;
  typedef struct packed { ea4::ph_e ph; logic q; } s_t;
endpackage
module top(output logic [1:0] o);
  parameter eb4::s_t S = 3'b010;
  assign o = '0;
endmodule
