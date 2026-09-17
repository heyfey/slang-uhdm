// v11u59 xv1 — THE DECOMPILE FACE, VALUES THAT FIT.  The removed writes were
// VpiValue("UINT:"+dec) AND VpiDecompile(dec).  Wherever a value FITS its
// member the VALUE half is the identity, but the DECOMPILE half is NOT unless
// our own pre-existing decompile is already bare decimal digits.  If any cell
// here reads a SIZED or BASED decompile in our pristine listing while golden
// reads bare digits, the removal is a pristine-right -> patched-wrong move.
package pk;
  localparam bit [7:0]     PH  = 8'hF;      // fits an 8-bit member
  localparam bit [7:0]     PB  = 8'b1010;   // fits
  localparam bit [7:0]     PD  = 8'd9;      // fits
  localparam logic [15:0]  PL  = 16'h00FF;  // fits an 8-bit member exactly
  localparam int unsigned  PU  = 32'h1F;    // fits
  typedef enum bit [7:0] { Q0 = 8'h00, QH = 8'h2A } q_t;
  typedef struct packed {
    logic [7:0]   H;   // PH
    logic [7:0]   B;   // PB
    logic [7:0]   D;   // PD
    logic [7:0]   L;   // PL
    logic [7:0]   U;   // PU
    logic [7:0]   E;   // QH (enum member, sized)
    logic [127:0] W;   // 128'(0) -> the walk returns here (tagged state)
    int unsigned  Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = {c.H, c.B, c.D, c.L};
    r.G = (c.U > 0) ^ (c.E > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ H: PH, B: PB, D: PD, L: PL, U: PU, E: QH,
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
