// § memberEnumCloneKeepsBase147
package ea;
  typedef enum logic [2:0] {Lo = 3'd1, Hi = 3'd4} lv_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { lv_e l; logic [1:0] n; } cfg_t;
endpackage
module top(output logic [2:0] o);
  import eb::*;
  parameter cfg_t Cfg = '{l: ea::Hi, n: 2'd1};
  assign o = Cfg.l;
endmodule
