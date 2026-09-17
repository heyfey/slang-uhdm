// r11u59 wa3 — THE MASK HALF, SIGNEDNESS.  A SIGNED member fed an over-wide
// reference, a signed member fed a NEGATIVE reference, an unsigned member fed a
// negative reference, and a signed member whose value fits.  A mask written
// with `uv &= (1<<w)-1` cannot represent a negative element; golden's own cells
// say whether there is anything to represent.
package pk;
  localparam int unsigned BIG  = 300;
  localparam int signed   NEG  = -5;
  localparam int signed   NEGB = -300;
  typedef struct packed {
    logic signed [7:0] SB;  // BIG  -> size 8, over-wide into a signed member
    byte signed        SN;  // NEG  -> size 8, negative into a signed member
    logic [7:0]        UN;  // NEG  -> size 8, negative into an UNSIGNED member
    shortint signed    SW;  // NEGB -> size 16, fits
    logic [127:0]      W;   // 128'(0) -> the walk returns here
    int unsigned       Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = {c.SB, c.SN, c.UN, c.SW[7:0]};
    r.G = (c.SW != 0);
    return r;
  endfunction
  localparam u_t BASE = '{ SB: BIG, SN: NEG, UN: NEG, SW: NEGB,
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
