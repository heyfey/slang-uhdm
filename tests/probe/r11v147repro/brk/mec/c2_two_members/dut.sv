// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [1:0] {Idle, Run, Stop} st_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e a; st_e b; } cfg_t;
endpackage
module top(output logic [3:0] o);
  import eb::*;
  parameter cfg_t Cfg = 4'b0110;
  assign o = Cfg;
endmodule
