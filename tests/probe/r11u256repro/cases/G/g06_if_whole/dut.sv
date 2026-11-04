// § genIpsBoundOwner256 (if-generate, the select the whole right side (Earlgrey gen_word_sel))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  if (LB == 2) begin : gs
    assign q = '0;
  end else begin : gw
    assign q = a[0 +: LB];
  end
  assign o = b[3:0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
