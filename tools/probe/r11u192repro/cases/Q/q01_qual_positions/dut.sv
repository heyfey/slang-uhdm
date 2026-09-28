// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = $clog2(16);
  localparam int unsigned L = 4;
endpackage
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4,
  output logic [31:0] y5, output logic [31:0] y6, output logic [31:0] y7, output logic [31:0] y8, output logic [31:0] y9);
  assign y1 = x[p::S:0];
  assign y2 = x[31:p::L];
  assign y3 = x[p::S];
  assign y4 = x + p::S;
  assign y5 = {p::S{1'b0}};
  assign y6 = x[p::S-1:0];
  wire [31:0] w7 = x[p::S:0];
  assign y7 = w7;
  always_comb y8 = x[p::S:0];
  function automatic logic [31:0] f(input logic [31:0] a);
    return a[p::S:0];
  endfunction
  assign y9 = f(x);
endmodule
