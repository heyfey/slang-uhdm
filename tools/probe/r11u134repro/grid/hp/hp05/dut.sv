// § tsHierPathElemNoName134
package cp;
  typedef struct packed {
    int unsigned W;
  } cfg_t;
  localparam cfg_t Def = '{W: 32'd8};
endpackage
module top #(parameter cp::cfg_t Cfg = cp::Def) (
    input  logic sel,
    output logic [Cfg.W-1:0] o
);
  localparam type pair_t = struct packed {
    logic [Cfg.W-1:0] a;
    logic [Cfg.W-1:0] b;
  };
  localparam pair_t P = '{a: Cfg.W'(1), b: Cfg.W'(2)};
  assign o = sel ? P.a : P.b;
endmodule
