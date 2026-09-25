// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [1:0] {Idle = 2'd0, Busy = 2'd2} st_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e mode; } in_t;
  typedef struct packed { in_t i; logic en; } cfg_t;
endpackage
module top(output logic [2:0] o);
  import eb::*;
  parameter cfg_t Cfg = 3'b101;
  assign o = Cfg;
endmodule
