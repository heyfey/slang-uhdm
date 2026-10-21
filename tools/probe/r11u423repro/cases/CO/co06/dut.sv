// § clsTfOpFoldTsLate423 (a module process, not reached)
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
import p::*;
module top(input f_t x, output logic y);
  always_comb y = (x == A);
endmodule
