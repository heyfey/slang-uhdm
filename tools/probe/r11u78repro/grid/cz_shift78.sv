// Minimal reproducer of CVA6's `CVA6Cfg.XLEN` UH0725 blocker.
//
// A module parameter whose TYPE is a packed struct (`config_pkg::cva6_cfg_t
// CVA6Cfg`), with a FIELD of that parameter (`Cfg.XLEN`) read inside a
// `localparam type = struct packed { ... }` definition and a localparam
// initializer — exactly how core/cva6.sv builds its `interrupts_t` /
// `INTERRUPTS`.  Surelog raised UH0725 "Unresolved hierarchical reference
// Cfg.XLEN" for the struct-typed-parameter member access in the localparam-type
// context (it resolves fine in a port width).
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    int unsigned VLEN;
  } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd64, VLEN: 32'd64};
  typedef struct packed { logic [63:0] a; logic [7:0] p1; logic [7:0] p2; } pe_t;
  localparam bit [95:0] WIDEDEC = 96'd18446744073709551616;
  localparam int        KK      = 6;
  localparam pe_t PE1 = '{a: 8'sd200 >>> 1, p1: KK+1, p2: KK+2};
  localparam pe_t PE0 = '{a: KK*2,        p1: KK+1, p2: KK+2};
endpackage

module cy76 #(
    parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg,
    parameter cfg_pkg::pe_t  PA  = cfg_pkg::PE1,
    parameter cfg_pkg::pe_t  PB  = cfg_pkg::PE0
) (
    input  logic                a_i,
    output logic [Cfg.XLEN-1:0] b_o
);
  // localparam TYPE whose struct field widths reference the struct-param field.
  localparam type it_t = struct packed {
    logic [Cfg.XLEN-1:0] x;
    logic [Cfg.XLEN-1:0] y;
  };
  localparam it_t I = '{x: Cfg.XLEN'(1), y: Cfg.XLEN'(2)};
  assign b_o = a_i ? I.x : I.y;
  logic [63:0] ea; assign ea = PA.a;
  logic [7:0] e1; assign e1 = PA.p1;
  logic [7:0] e2; assign e2 = PA.p2;
  logic [63:0] fa; assign fa = PB.a;
  logic [7:0] f1; assign f1 = PB.p1;
endmodule
