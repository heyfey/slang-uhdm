// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [1:0] {Idle = 2'd0, Busy = 2'd2} st_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e mode; logic en; } cfg_t;
endpackage
module top(input eb::cfg_t c, output logic [2:0] o);
  assign o = c;
endmodule
