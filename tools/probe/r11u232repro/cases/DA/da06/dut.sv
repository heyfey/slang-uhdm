// § defAggParamBindsImportClone232
package p;
  typedef struct packed {
    int unsigned a;
    bit f;
  } cfg_t;
  typedef union packed {
    logic [32:0] w;
    cfg_t       c;
  } cu_t;
  localparam cfg_t C = '{a: 5, f: 1};
endpackage
interface ifc import p::*; #(parameter cfg_t Cfg = '0) ();
  int unsigned a;
  assign a = Cfg.a;
endinterface
module top(output logic [3:0] o);
  ifc #(.Cfg(p::C)) i ();
  assign o = i.a;
endmodule
