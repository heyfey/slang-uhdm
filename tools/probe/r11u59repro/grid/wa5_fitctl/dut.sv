// r11u59 wa5 — THE FITTING CONTROL, and the DECOMPILE face.  Every element's
// reference value FITS its member, so the mask itself is the identity; what is
// left is whether the landed arm's `VpiDecompile(std::to_string(uv))` rewrite is
// also the identity.  If golden's element decompiles as something other than
// bare decimal digits at any of these widths/bases, the decompile rewrite is a
// SECOND divergence on cells the corpus really has.
package pk;
  localparam int unsigned SEVEN = 7;
  localparam int unsigned HX    = 32'h1F;
  localparam int unsigned BN    = 32'b1011;
  localparam bit [7:0]    SZ    = 8'd9;
  typedef struct packed {
    logic [7:0]   A;   // SEVEN
    logic [7:0]   H;   // HX
    logic [7:0]   B;   // BN
    logic [7:0]   S;   // SZ
    logic         O;   // 1'b1 through a reference that fits exactly
    logic [127:0] W;   // 128'(0) -> the walk returns here
    int unsigned  Z;
  } u_t;
  localparam bit ONE = 1'b1;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = {c.A, c.H, c.B, c.S};
    r.G = c.O;
    return r;
  endfunction
  localparam u_t BASE = '{ A: SEVEN, H: HX, B: BN, S: SZ, O: ONE,
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
