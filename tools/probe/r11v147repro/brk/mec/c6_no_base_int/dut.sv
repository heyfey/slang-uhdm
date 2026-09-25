// § memberEnumCloneKeepsBase147
package ea;
  typedef enum {Idle, Run} st_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e s; logic v; } cfg_t;
endpackage
module top(output logic o);
  import eb::*;
  parameter cfg_t Cfg = '{s: ea::Run, v: 1'b1};
  assign o = Cfg.v;
endmodule
