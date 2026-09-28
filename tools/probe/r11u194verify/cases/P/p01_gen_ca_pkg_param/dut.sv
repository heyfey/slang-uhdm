// § pkgParamElabCaSharesDefFold183: a package parameter read in continuous assignments inside an if-generate and a generate-for of an instanced module (elaborated continuous assignments)
package p;
  parameter int unsigned X = 7;
  parameter logic [7:0] Y = 8'h21;
endpackage
module m (output int a, output logic [7:0] b [2]);
  import p::*;
  if (X > 3) begin : gi
    assign a = X;
  end
  for (genvar i = 0; i < 2; i++) begin : gf
    assign b[i] = Y;
  end
endmodule
module top (output int o, output logic [7:0] q [2]);
  m u (.a(o), .b(q));
endmodule
