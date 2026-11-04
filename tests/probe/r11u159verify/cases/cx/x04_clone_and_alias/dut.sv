// § memberEnumCloneKeepsBase147 § packedElemAliasTypedef152
package ea;
  typedef enum logic [1:0] {Idle = 2'd0, Busy = 2'd2} st_e;
  typedef st_e st_t;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e mode; logic en; } cfg_t;
endpackage
module top(output logic [2:0] o, output logic [3:0] p);
  import eb::*;
  parameter cfg_t Cfg = 3'b101;
  ea::st_t [1:0] w;
  assign w = {ea::Busy, ea::Idle};
  assign o = Cfg;
  assign p = w;
endmodule
