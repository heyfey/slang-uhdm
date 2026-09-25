// § memberEnumCloneKeepsBase147
// case f05: the member enum reaches a sub-module parameter through an instance override (two levels)
package ea5;
  typedef enum logic [1:0] {M0 = 2'd0, M3 = 2'd3} md_e;
endpackage
package eb5;
  import ea5::*;
  typedef struct packed { md_e md; logic v; } k_t;
endpackage
module leaf(output logic [1:0] o);
  import ea5::*;
  parameter md_e MD = M0;
  assign o = MD;
endmodule
module top(output logic [1:0] o);
  import eb5::*;
  parameter k_t K = 3'b111;
  leaf #(.MD(K.md)) u(.o(o));
endmodule
