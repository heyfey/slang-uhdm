// § pkgQualBoundSpanTernary298
// a ternary bound on a this. path in a class method
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
package q;
  class c;
    logic [31:0] v;
    function logic [31:0] f(); return 32'(this.v[(pk::DC ? pk::DC : pk::N)-1:0]); endfunction
  endclass
endpackage
module top; endmodule
