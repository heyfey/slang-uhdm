// r11u59 wa2 — THE MASK HALF, BASES.  The same over-wide value (300) reaching
// five 8-bit members through references written in five different bases, plus
// one written as a sized literal reference.  Which vpiConstType / value field
// does golden's elaborated element carry, and does the base survive the
// member-width re-size?  (Our § patElabUintResize arm fires only on a
// vpiUIntConst element and rewrites vpiDecompile to decimal digits, so the
// encoding is part of the law's surface, not just the value.)
package pk;
  localparam int unsigned DEC300 = 300;
  localparam int unsigned HEX300 = 32'h12C;
  localparam int unsigned BIN300 = 32'b1_0010_1100;
  localparam int unsigned OCT300 = 32'o454;
  localparam bit [15:0]   SZD300 = 16'd300;
  typedef struct packed {
    logic [7:0]   D;   // DEC300
    logic [7:0]   H;   // HEX300
    logic [7:0]   B;   // BIN300
    logic [7:0]   O;   // OCT300
    logic [7:0]   S;   // SZD300
    logic [127:0] W;   // 128'(0) -> the walk returns here
    int unsigned  Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = {c.D, c.H, c.B, c.O};
    r.G = (c.S > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ D: DEC300, H: HEX300, B: BIN300, O: OCT300,
                           S: SZD300, W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
