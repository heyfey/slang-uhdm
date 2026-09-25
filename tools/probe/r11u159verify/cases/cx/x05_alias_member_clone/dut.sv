// § memberEnumCloneKeepsBase147 § packedElemAliasTypedef152
package ea;
  typedef enum logic [1:0] {Idle = 2'd0, Busy = 2'd2} st_e;
  typedef st_e st_t;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_t mode; ea::st_t [1:0] hist; } cfg_t;
endpackage
module top(output logic [5:0] o);
  import eb::*;
  parameter cfg_t Cfg = 6'b101010;
  assign o = Cfg;
endmodule
