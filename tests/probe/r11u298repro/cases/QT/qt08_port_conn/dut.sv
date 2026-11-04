// § pkgQualBoundSpanTernary298
// a ternary bound in a port connection
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module sub (input logic [7:0] a, output logic [7:0] o); assign o = a; endmodule
module top (input logic [31:0] d, output logic [7:0] y);
  sub u (.a(8'(d[(pk::DC ? pk::DC : pk::N)-1:0])), .o(y));
endmodule
