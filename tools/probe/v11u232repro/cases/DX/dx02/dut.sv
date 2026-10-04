// § defAggParamBindsImportClone232
package p;
  typedef struct packed { int unsigned a; bit f; } cfg_t;
  localparam cfg_t C = '{a: 5, f: 1};
endpackage
import p::*;
// a file-level import, body parameters (not the header)
module child (input logic x, output logic [3:0] y);
  parameter cfg_t Cfg = '0;
  assign y = {Cfg.a[1:0]{x}};
endmodule
module top (input logic x, output logic [3:0] y);
  parameter cfg_t Cfg = C;
  child #(.Cfg(Cfg)) u_c (.x(x), .y(y));
endmodule
