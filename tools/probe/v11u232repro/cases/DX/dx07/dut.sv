// § defAggParamBindsImportClone232
package p;
  typedef struct packed { int unsigned a; bit f; } cfg_t;
endpackage
// an interface with the struct parameter, and a module
interface ifc import p::*; #(parameter cfg_t Cfg = '0) ();
  logic [Cfg.a-1:0] v;
endinterface
module top import p::*; #(parameter cfg_t Cfg = '{a: 3, f: 0}) (output logic [2:0] y);
  ifc #(.Cfg(Cfg)) i ();
  assign i.v = '1;
  assign y = i.v;
endmodule
