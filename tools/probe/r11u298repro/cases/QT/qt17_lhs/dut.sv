// § pkgQualBoundSpanTernary298
// a ternary bound on an assignment target
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  always_comb begin
    y = '0;
    y[(pk::DC ? pk::DC : pk::N)-1:0] = d[3:0];
  end
endmodule
