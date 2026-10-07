// § insideSetParamFoldKeepsPa270
package up;
  typedef logic [3:0] nib_t;
  parameter nib_t A = 4'h3;
  parameter logic [7:0] B = 8'hF0;
  parameter string S = "x";
endpackage
module top;
  import up::*;
  function automatic bit f(logic [7:0] w, string s);
    return (w inside {A, B}) && (s inside {S, "y"});
  endfunction
endmodule
