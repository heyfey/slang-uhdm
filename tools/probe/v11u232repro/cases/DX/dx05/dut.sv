// § defAggParamBindsImportClone232
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } cfg_t;
  localparam cfg_t C = '{a: 4'd2, b: 4'd3};
endpackage
// constant slots: dimension bound, part-select bounds, indexed width, replication count; two levels
module leaf import p::*; #(parameter cfg_t Cfg = '0) (input logic [15:0] x, output logic [Cfg.a:0] y, output logic [7:0] z, output logic [7:0] r);
  assign y = x[Cfg.a:0];
  assign z = x[Cfg.b +: 4];
  assign r = {Cfg.b{x[0]}};
endmodule
module child import p::*; #(parameter cfg_t Cfg = '0) (input logic [15:0] x, output logic [Cfg.a:0] y, output logic [7:0] z, output logic [7:0] r);
  leaf #(.Cfg(Cfg)) l (.x(x), .y(y), .z(z), .r(r));
endmodule
module top import p::*; #(parameter cfg_t Cfg = C) (input logic [15:0] x, output logic [2:0] y, output logic [7:0] z, output logic [7:0] r);
  child #(.Cfg(Cfg)) u_c (.x(x), .y(y), .z(z), .r(r));
endmodule
