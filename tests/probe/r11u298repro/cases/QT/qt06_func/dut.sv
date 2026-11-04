// § pkgQualBoundSpanTernary298
// a ternary bound in a function body
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  function automatic logic [31:0] f(input logic [31:0] v); return 32'(v[(pk::DC ? pk::DC : pk::N)-1:0]); endfunction
  assign y = f(d);
endmodule
