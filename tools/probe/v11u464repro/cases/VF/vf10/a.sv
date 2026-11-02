// § unitImpTfNameDedup464 (control: the two imports in two files; first importer)
import p1::*;
module sub(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
