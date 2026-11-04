// § elabBodyIpsBoundSelName256 (the module's own localparam and header parameter as bounds (control))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m #(parameter int HP = 3) (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  localparam int LF = 2;
  assign q = c ? a[LF +: HP] : '0;
  assign o = {c, b[LF +: HP]};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
