// r11u59 wa6 — THE ONE VALUE THE PRODUCER DOES REWRITE.  `adjustUnsized`
// (Surelog `CompileHelper.cpp:5091`) is the only line in the stamp that touches
// a value, and it acts only on a constant whose `VpiSize()` is -1 (an UNBASED
// UNSIZED literal) holding 1: it then writes the all-ones mask AT THE MEMBER
// WIDTH into vpiValue and vpiDecompile.  So the no-mask law needs its
// exception cut: an `'1` element written directly, an `'1` reached through a
// parameter, and an `'0` (value 0, which `adjustUnsized` leaves alone).
package pk;
  localparam bit [7:0] ALL1 = '1;
  typedef struct packed {
    logic [7:0]   U1;  // '1   written directly
    logic [7:0]   RP;  // ALL1 through a reference
    logic [7:0]   U0;  // '0   written directly
    logic [127:0] W;   // 128'(0) -> the walk returns here
    int unsigned  Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = {c.U1, c.RP, c.U0, 8'd0};
    r.G = (c.Z > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ U1: '1, RP: ALL1, U0: '0,
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
