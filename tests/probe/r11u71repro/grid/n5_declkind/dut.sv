// r11u71 n5 — LAW A's DECODE CONTROL.  What does golden carry for the gen-scope
// DECLARATION that a substituted cont_assign drives, and what does its Lhs ref
// point at?  Five declaration kinds, each gen-local with no namesake.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  localparam cfg_t LIT = '{n: 300, m: 8'hA5};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  if (1) begin : g
    logic [31:0] d_logic;
    reg   [31:0] d_reg;
    wire  [31:0] d_wire;
    bit   [31:0] d_bit;
    integer      d_int;
    logic [31:0] d_undriven;   // CONTROL: declared, never assigned
    assign d_logic = CFG.n;
    assign d_reg   = CFG.n;
    assign d_wire  = CFG.n;
    assign d_bit   = CFG.n;
    assign d_int   = CFG.n;
    assign o = {32'd0, d_logic} ^ {32'd0, d_reg} ^ {32'd0, d_wire}
               ^ {32'd0, d_bit} ^ {32'd0, d_int} ^ {32'd0, d_undriven};
  end
endmodule
