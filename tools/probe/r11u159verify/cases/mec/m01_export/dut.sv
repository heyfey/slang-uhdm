// § memberEnumCloneKeepsBase147
package ea;
  typedef enum bit [2:0] {Idle = 3'd0, Busy = 3'd5} st_e;
endpackage
package eb;
  import ea::*;
  export ea::*;
  typedef struct packed { st_e mode; logic en; } cfg_t;
endpackage
module top(output logic [3:0] o);
  import eb::*;
  parameter cfg_t Cfg = 4'b1011;
  assign o = Cfg;
endmodule
