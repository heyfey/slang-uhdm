// § pkgParamFoldOwnTs183: package parameters of a logic range type with bare decimal defaults read in a generate block's continuous assignment and in a module-level one
package p;
  parameter logic [3:0] Z = 3;
  parameter logic [11:0] ZZ = 100;
endpackage
module m (output logic [3:0] a, output logic [11:0] b);
  import p::*;
  if (1) begin : g
    assign a = Z;
  end
  assign b = ZZ;
endmodule
module top (output logic [3:0] o, output logic [11:0] q);
  m u (.a(o), .b(q));
endmodule
