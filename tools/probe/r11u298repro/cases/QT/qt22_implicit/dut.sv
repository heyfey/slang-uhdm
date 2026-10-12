// § pkgQualBoundSpanTernary298
// a ternary bound on an implicit net in a port connection and a named call argument
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module sub (input logic [7:0] a, output logic [7:0] o); assign o = a; endmodule
module top (output logic [7:0] y);
  function automatic logic [7:0] g(input logic [7:0] x); return x; endfunction
  sub u (.a(8'hA5), .o(w));
  assign y = g(.x(8'(w[(pk::DC ? pk::DC : pk::N)-1:0])));
endmodule
