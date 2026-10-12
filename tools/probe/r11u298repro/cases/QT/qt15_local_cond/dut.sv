// § pkgQualBoundSpanTernary298
// a local parameter as the condition, qualified branches
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top #(parameter bit C = 1) (input logic [31:0] d, output logic [31:0] y);
  always_comb y = 32'(d[(C ? pk::DC : pk::N)-1:0]);
endmodule
