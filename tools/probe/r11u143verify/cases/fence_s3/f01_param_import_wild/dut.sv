// residue S3 of r11u137 (N0057, the struct member enum copy of a package import clone): fence re-derivation
// case f01: package B wildcard-imports package A and types a struct member with A's enum; top parameter of B's struct
package ea;
  typedef enum logic [1:0] {Idle = 2'd0, Busy = 2'd2} st_e;
endpackage
package eb;
  import ea::*;
  typedef struct packed { st_e mode; logic en; } cfg_t;
endpackage
module top(output logic [1:0] o);
  import eb::*;
  parameter cfg_t Cfg = 3'b101;
  assign o = Cfg.mode;
endmodule
