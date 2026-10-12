// § pkgQualBoundSpanTernary298
// a ternary bound on an increment operand and a streaming target
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  logic [31:0] r;
  always_comb begin
    r = d;
    r[(pk::DC ? pk::N : pk::M):0]++;
    {>>{r[(pk::N ? pk::M : pk::N):0]}} = d[5:0];
    y = r;
  end
endmodule
