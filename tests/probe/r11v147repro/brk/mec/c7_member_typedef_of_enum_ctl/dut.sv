// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [1:0] {Idle, Run} st_e;
  typedef st_e alias_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { alias_e s; logic v; } cfg_t;
endpackage
module top(output logic [2:0] o);
  import eb::*;
  parameter cfg_t Cfg = 3'b011;
  assign o = Cfg;
endmodule
