// § pkgQualBoundSpanTernary298
// a ternary bound inside a function call argument and a system call argument
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top (input logic [31:0] d, output logic [31:0] y, output int c);
  function automatic logic [31:0] f(logic [31:0] v); return v + 1; endfunction
  assign y = f(32'(d[(pk::DC ? pk::N : pk::M):0]));
  assign c = $countones(d[(pk::N ? pk::DC : pk::M):0]);
endmodule
