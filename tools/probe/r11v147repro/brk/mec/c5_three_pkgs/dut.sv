// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [1:0] {Idle, Run} st_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e s; logic v; } in_t;
endpackage
package ec;
  import eb::*;
  typedef struct packed { in_t i; logic w; } out_t;
endpackage
module top(output logic [3:0] o);
  import ec::*;
  parameter out_t P = 4'b1011;
  assign o = P;
endmodule
