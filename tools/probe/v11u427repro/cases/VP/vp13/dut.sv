// § xzPkgLeafFoldIsRhsCopy427
package p;
  localparam B = 4'b1x01;
  function automatic logic [3:0] f(); return B; endfunction
endpackage
module top(output [3:0] o);
  assign o = p::f();
endmodule
