// § pkgQualBoundSpanTernary298
// a wildcard import beside the qualified reads, and an unqualified read
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top import pk::*; (input logic [31:0] d, output logic [31:0] y, output logic [31:0] z);
  always_comb begin
    y = 32'(d[(pk::DC ? pk::DC : pk::N)-1:0]);
    z = 32'(d[(DC ? DC : N)-1:0]);
  end
endmodule
