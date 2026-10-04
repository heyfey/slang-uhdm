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
  typedef cfg_t cfg2_t;
  localparam cfg_t C = '{a: 5, f: 1};
endpackage
// an interface and a module with the parameter, three levels
interface ifc import p::*; #(parameter cfg_t Cfg = '0) ();
  logic [Cfg.a-1:0] v;
endinterface
module leaf import p::*; #(parameter cfg_t Cfg = '0) (output logic [3:0] y);
  ifc #(.Cfg(Cfg)) i ();
  assign i.v = '1;
  assign y = i.v;
endmodule
module mid import p::*; #(parameter cfg_t Cfg = '0) (output logic [3:0] y);
  leaf #(.Cfg(Cfg)) l (.y(y));
endmodule
module top(output logic [3:0] y);
  mid #(.Cfg(p::C)) m (.y(y));
endmodule
