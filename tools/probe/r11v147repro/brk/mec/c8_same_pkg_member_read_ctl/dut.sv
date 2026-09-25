// § memberEnumCloneKeepsBase147
package eb;
  typedef enum logic [1:0] {Idle = 2'd0, Busy = 2'd2} st_e;
  typedef struct packed { st_e mode; logic en; } cfg_t;
endpackage
module top(output logic [1:0] o);
  import eb::*;
  parameter cfg_t Cfg = 3'b101;
  assign o = Cfg.mode;
endmodule
