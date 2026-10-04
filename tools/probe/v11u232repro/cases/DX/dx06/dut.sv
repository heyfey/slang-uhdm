// § defAggParamBindsImportClone232
package p;
  typedef struct packed { int unsigned a; bit f; } cfg_t;
endpackage
// a localparam typed by the struct in the body, a generate-block instance
module child import p::*; #(parameter cfg_t Cfg = '0) (input logic x, output logic y);
  localparam cfg_t L = '{a: Cfg.a + 1, f: ~Cfg.f};
  assign y = L.f ? x : 1'b0;
endmodule
module top import p::*; #(parameter cfg_t Cfg = '{a: 1, f: 0}) (input logic x, output logic y);
  if (1) begin : g
    child #(.Cfg(Cfg)) u_c (.x(x), .y(y));
  end
endmodule
