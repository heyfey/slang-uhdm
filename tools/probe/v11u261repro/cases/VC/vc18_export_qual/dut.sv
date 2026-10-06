// § qselPkgParamOnly261v
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
package cq;
  import cp::RC;
  export cp::RC;
  parameter logic [3:0][7:0] QC = {8'h55, 8'h66, 8'h77, 8'h88};
endpackage
module top (input logic [3:0] a, output logic [3:0] o [2], output logic [3:0] q [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = a ^ cq::RC[k][3:0];
    assign q[k] = a ^ cq::QC[k][3:0];
  end
endmodule
