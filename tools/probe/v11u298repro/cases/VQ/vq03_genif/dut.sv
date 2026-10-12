// § pkgQualBoundSpanTernary298
// a ternary bound in an if-generate continuous assignment and a case-generate process
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top #(parameter int K = 1) (input logic [31:0] d, output logic [31:0] y, output logic [31:0] z);
  if (K == 1) begin : g
    assign y = 32'(d[(pk::DC ? pk::N : pk::M)-1:0]);
  end
  case (K)
    1: begin : c
      always_comb z = 32'(d[(pk::M ? pk::N : pk::DC):0]);
    end
  endcase
endmodule
