// § callArgVarSelStamp198
package pk; function automatic logic [3:0] pf(input logic [3:0] x); return x + 1; endfunction endpackage
module top (input logic [3:0] p [2][4], output logic [3:0] y, output logic [3:0] z);
  assign y = pk::pf(p[1][2]);
  logic [3:0] w = pk::pf(p[0][3]);
  assign z = w;
endmodule
