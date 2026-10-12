// § pkgQualBoundSpanTernary298
// control: a ternary bound in a parameter initializer
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (output logic [31:0] y);
  localparam logic [31:0] K = 32'hABCD1234;
  localparam logic [31:0] L = 32'(K[(pk::DC ? pk::DC : pk::N)-1:0]);
  assign y = L;
endmodule
