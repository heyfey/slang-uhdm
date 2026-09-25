// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [1:0] {Idle, Run} st_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e s; logic v; } cfg_t;
endpackage
module top(input logic [2:0] i, output logic [1:0] o);
  eb::cfg_t c;
  assign c = i;
  assign o = c.s;
endmodule
