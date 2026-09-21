// v11u71 x2 — THE DELAY CLONE.  `writeCont_assign` sets `cloned = true` in the
// DELAY arm BEFORE the `if (var)` arm, and the reduce+adjustSize block is
// `if (cloned == false)`.  So a cont_assign with a ref_obj delay must NOT be
// re-sized even when `bindVariable` hits.  Four cells: delay x namesake.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT, parameter DLY = 3)
  (input logic a_i, output logic [63:0] o);
  logic [7:0] ns;            // module-body namesake, 8 bits
  logic [7:0] mbt;           // a module-level target, 8 bits
  if (1) begin : gd_ns
    logic [31:0] ns;         // namesake hit + DELAY
    assign #DLY ns = CFG.n;
  end
  if (1) begin : gd_no
    logic [31:0] lv;         // no namesake + DELAY
    assign #DLY lv = CFG.n;
  end
  if (1) begin : gd_mb
    assign #DLY mbt = CFG.n; // module-level target + DELAY (pass-68's half)
  end
  if (1) begin : gp_ns
    logic [31:0] ns;         // namesake hit, NO delay (control)
    assign ns = CFG.n;
  end
  assign o = {32'd0, gd_ns.ns} ^ {32'd0, gd_no.lv} ^ {56'd0, mbt}
           ^ {32'd0, gp_ns.ns};
  assign ns = 8'd0;
endmodule
