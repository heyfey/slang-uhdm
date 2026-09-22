// r11u86 arm m5 — THE BOUNDARIES of the module-route encoding face: octal
// digits that are NOT their own decimal, values at and past 64 bits, unknown
// digits, zero, a negated hop, a `default:` road and a DIRECT `16'sd5`.
package m5p;
  localparam PO17 = 16'o17;
  localparam PO77 = 16'o777;
  localparam PD10 = 16'd10;
  localparam PD0  = 16'd0;
  localparam PW96 = 96'd12;
  localparam PW65 = 65'd3;
  localparam PW64 = 64'd18446744073709551614;
  localparam PXD  = 16'dx;
  localparam PXO  = 16'ox;
  typedef struct packed {
    logic [95:0] bail; logic [95:0] a; logic [95:0] b; logic [95:0] c;
    logic [95:0] d;    logic [95:0] e; logic [95:0] f; logic [95:0] g;
    logic [95:0] h;    logic [95:0] i; logic [95:0] j;
  } t5;
endpackage
module m5_bnd86;
  localparam MSD = 16'sd5;
  localparam m5p::t5 MB = '{bail: 8'hxA,
    a: m5p::PO17, b: m5p::PO77, c: m5p::PD10, d: m5p::PD0, e: m5p::PW96,
    f: m5p::PW65, g: m5p::PW64, h: m5p::PXD,  i: m5p::PXO, j: 16'sd5};
endmodule
