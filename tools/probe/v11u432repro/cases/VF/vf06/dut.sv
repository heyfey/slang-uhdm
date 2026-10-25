// § caCallConcatArgFormalTs432
package pk;
  function automatic [3:0] f(input [5:0] b);
    return b[3:0];
  endfunction
endpackage
import pk::*;
module m(input [5:0] a, output [3:0] y);
  assign y = f({a[2:0], a[5:3]});
endmodule
