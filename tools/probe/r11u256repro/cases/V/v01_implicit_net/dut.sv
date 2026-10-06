// § genIpsBoundOwner256 (an implicit net target in a for-generate)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
module m import fp::*; (input logic [7:0] a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : gb
    assign imp = a[FW +: 1];
    assign o[i] = imp;
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] o); m u (.*); endmodule
