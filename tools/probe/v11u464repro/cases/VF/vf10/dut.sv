// § unitImpTfNameDedup464 (control: the two imports in two files)
import p2::*;
module top(input logic [1:0] i, output logic [1:0] o);
  sub u(.i(i), .o(o));
endmodule
