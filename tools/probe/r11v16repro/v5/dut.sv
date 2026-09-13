// v5 — MEMBER TYPESPEC KINDS not in the int/logic pair: enum, bit, byte,
// packed array, shortint; each read into a net of the member's own width.
package p;
  typedef enum logic [3:0] { A = 4'd1, B = 4'd2 } e_t;
  typedef struct packed {
    int unsigned n;
    e_t          e;
    bit [4:0]    bt;
    byte         by;
    logic [2:0][7:0] pa;
    shortint unsigned si;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n  = 9;
    c.e  = B;
    c.bt = 5'b10101;
    c.by = 8'h7F;
    c.pa = 24'h010203;
    c.si = 16'hBEEF;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [31:0] o_n,
    output wire [3:0]  o_e,
    output wire [4:0]  o_bt,
    output wire [7:0]  o_by,
    output wire [23:0] o_pa,
    output wire [15:0] o_si
);
  assign o_n  = CFG.n;
  assign o_e  = CFG.e;
  assign o_bt = CFG.bt;
  assign o_by = CFG.by;
  assign o_pa = CFG.pa;
  assign o_si = CFG.si;
endmodule
