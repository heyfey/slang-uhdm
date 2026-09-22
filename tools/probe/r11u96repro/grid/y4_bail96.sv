// r11u96 arm y4 — THE BAIL EDGES, kept off the scored grid so that a shape the
// producer REFUSES cannot poison a scored arm.  An unsized decimal whose digits
// overflow `int64`, and the int64 extremes of the three new operators.  A
// DIVISION BY A NAMED ZERO is not here: Surelog v1.87 raises `[ERR:UH0722]
// Division by zero` on `6 / Z0` and `6 % Z0`, so that shape has no golden at
// all (measured, `slrc=4 slerr=2`) and teaches error recovery, not the law.
package y4p;
  localparam longint OVF   = 99999999999999999999 - 1;
  localparam longint MMAX  = 9223372036854775807 * 2;
  localparam longint DMIN  = -9223372036854775807 / 1;
endpackage
module y4_bail96 (output logic [63:0] o);
  wire signed [63:0] wOVF  = y4p::OVF;
  wire signed [63:0] wMMAX = y4p::MMAX;
  wire signed [63:0] wDMIN = y4p::DMIN;
  assign o = wOVF ^ wMMAX ^ wDMIN;
endmodule
