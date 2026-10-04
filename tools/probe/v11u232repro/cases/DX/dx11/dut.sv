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
// two instances in a for-generate, one defaulted
module child import p::*; #(parameter cfg_t Cfg = '{a: 2, f: 0}) (output logic [3:0] y);
  logic [Cfg.a-1:0] w;
  assign w = '1;
  assign y = w;
endmodule
module top(output logic [3:0] y[2]);
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : a
      child #(.Cfg(p::C)) u_c (.y(y[i]));
    end else begin : b
      child u_c (.y(y[i]));
    end
  end
endmodule
