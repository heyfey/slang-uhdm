// § dupImportSameValueKeeps252
package p;
parameter int unsigned U = 10;
parameter int N = -5;
parameter logic [7:0] H = 8'hff;
parameter bit [3:0] Bt = 4'b1010;
parameter integer I = 12;
endpackage
import p::*;
module top(output logic [7:0] o, output logic signed [7:0] s);
  assign o = U + H + Bt + I;
  assign s = N;
endmodule
