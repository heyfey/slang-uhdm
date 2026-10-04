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
module child #(parameter p::cfg_t K = '0) (output logic y);
  import p::cfg_t;
  localparam cfg_t L = K;
  assign y = L.f;
endmodule
module top(output logic y);
  child #(.K(p::C)) u_c (.y(y));
endmodule
