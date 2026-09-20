// r11v69 w10 — WHAT SIZE DOES GOLDEN GIVE THE DECLINED "SHARE" CELL?  Every Lhs
// here is gen-local with NO namesake anywhere, so `bindVariable` finds nothing
// and `tps` stays null.  The member width and the Lhs width are made DIFFERENT
// in both directions so the answer names its own source.
package p;
  typedef struct packed {
    logic [7:0]  m8;
    int unsigned n32;
    logic [63:0] w64;
  } cfg_t;
  localparam cfg_t LIT = '{m8: 8'hA5, n32: 300, w64: 64'd70000};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o1, o2, o3, o4);
  if (1) begin : g
    logic [31:0] wide_from_m8;   // member 8  -> Lhs 32
    logic [7:0]  narrow_from_n32;// member 32 -> Lhs 8
    logic [31:0] narrow_from_w64;// member 64 -> Lhs 32
    logic [63:0] wide_from_n32;  // member 32 -> Lhs 64
    assign wide_from_m8    = CFG.m8;
    assign narrow_from_n32 = CFG.n32;
    assign narrow_from_w64 = CFG.w64;
    assign wide_from_n32   = CFG.n32;
    assign o1 = {32'd0, wide_from_m8};
    assign o2 = {56'd0, narrow_from_n32};
    assign o3 = {32'd0, narrow_from_w64};
    assign o4 = wide_from_n32;
  end
endmodule
