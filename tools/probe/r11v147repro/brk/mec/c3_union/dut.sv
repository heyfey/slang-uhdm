// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [1:0] {Idle, Run} st_e;
endpackage
package eb;
  import ea::*;
  typedef union packed { st_e s; logic [1:0] raw; } u_t;
endpackage
module top(output logic [1:0] o);
  import eb::*;
  parameter u_t U = 2'b01;
  assign o = U.raw;
endmodule
