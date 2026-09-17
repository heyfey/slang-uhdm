// r11u59 wa4 — LITERAL vs REFERENCE at the same over-wide value.  The landed
// § patElabUintResize arm re-sizes (and masks) only an element whose written
// value is a REFERENCE (`refMem9`); a literal element is left alone.  This arm
// puts the two side by side at the same 8-bit member width and the same 300, so
// golden's answer for the pair is one table.  It also carries an ENUM-member
// reference (the gate's other accepted symbol kind) and a CAST-wrapped
// reference (the gate strips up to eight conversions).
package pk;
  localparam int unsigned BIG = 300;
  typedef enum int unsigned { E0 = 0, EBIG = 300 } e_t;
  typedef struct packed {
    logic [7:0]   LIT;  // 300         literal
    logic [7:0]   REF;  // BIG         reference
    logic [7:0]   ENU;  // EBIG        enum member
    logic [7:0]   CST;  // unsigned'(BIG)  cast-wrapped reference
    logic [127:0] W;    // 128'(0) -> the walk returns here
    int unsigned  Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = {c.LIT, c.REF, c.ENU, c.CST};
    r.G = (c.Z > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ LIT: 300, REF: BIG, ENU: EBIG, CST: unsigned'(BIG),
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
