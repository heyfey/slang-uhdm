// § genIpsBoundOwner256 (a parameterized child specialized with a select width in a for-generate)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
module ch #(parameter int W = 1) (input logic [W-1:0] d, output logic y); assign y = ^d; endmodule
module m import fp::*; (input logic [7:0] a, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gb
    ch #(.W(PW)) u (.d(a[FW +: PW]), .y(o[i]));
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o); m u (.*); endmodule
