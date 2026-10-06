// § pkgSelIdxRefColons254 (an implicit net as the target of a two-level package select, and a replication count driving an implicit net)
package cp;
  parameter logic [1:0][3:0][7:0] R3 = '1;
  parameter int N = 1;
endpackage
module sub (input logic a, output logic o); assign o = a; endmodule
module top #(parameter int W = 1) (output logic o);
  import cp::*;
  assign imp = cp::R3[W][W-1];
  sub s (.a({N{imp}}), .o(o));
endmodule
