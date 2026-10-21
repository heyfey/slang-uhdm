// § clsTfOpFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
  parameter f_t B = 3;
endpackage
module top(input logic [27:0] x, output logic [27:0] y, output logic [27:0] z);
  import p::*;
  function automatic f_t f(f_t a);
    return (a | A) & B;
  endfunction
  assign y = f(x);
  always_comb z = x & A;
endmodule
