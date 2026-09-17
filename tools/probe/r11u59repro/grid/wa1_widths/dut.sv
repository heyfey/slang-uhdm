// r11u59 wa1 — THE MASK HALF, WIDTHS.  Every early member is fed a REFERENCE
// whose value does NOT fit it, at five different member widths.  The 128-bit
// member `W` ends the producer's walk (`shift >= 64`), which is also what keeps
// golden's elaborated listing TAGGED, so each cell is readable by name.
//   golden question: does the elaborated element keep its FULL value at the
//   member's vpiSize, or is the value masked to the member width?
package pk;
  localparam int unsigned      BIG   = 300;          // > 1, > 15, > 255
  localparam int unsigned      HUGE  = 70000;        // > 65535
  localparam longint unsigned  GIANT = 5000000000;   // > 2**32-1
  typedef struct packed {
    logic         M1;   // BIG   -> size 1
    logic [3:0]   M4;   // BIG   -> size 4
    logic [7:0]   M8;   // BIG   -> size 8
    logic [15:0]  M16;  // HUGE  -> size 16
    int unsigned  M32;  // GIANT -> size 32
    logic [127:0] W;    // 128'(0) -> size 128, then the walk returns
    int unsigned  Z;    // unsigned'(64) -> stays at its compiled size
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.M32;
    r.G = (c.M8 > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ M1: BIG, M4: BIG, M8: BIG, M16: HUGE, M32: GIANT,
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
