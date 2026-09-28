// § pkgArrTdElemClone209: a synthesizable package array-of-struct typedef, members read and written
package pkg;
  typedef struct packed { logic [3:0] x; logic y; } a;
  typedef a [1:0] b;
endpackage
module top (input logic clk, input pkg::b i, output logic [3:0] o, output logic y);
  pkg::b c;
  always_ff @(posedge clk) begin
    c <= i;
    c[0].y <= i[1].y;
  end
  assign o = c[1].x;
  assign y = c[0].y;
endmodule
