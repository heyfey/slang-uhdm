// § pkgQualBoundSpanTernary298
// a ternary bound inside a function of another package reading pk
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
package q;
  function automatic logic [31:0] g(logic [31:0] v);
    return 32'(v[(pk::DC ? pk::N : pk::M):0]);
  endfunction
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  assign y = q::g(d);
endmodule
