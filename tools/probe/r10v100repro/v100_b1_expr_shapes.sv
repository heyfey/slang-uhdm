// r10v100: expression shapes absent from the implementer grid.
package v100p1;
  parameter time P = 3;
  function automatic time bump(input time x);
    return x + 1;
  endfunction
endpackage
module v100_b1;
  import v100p1::*;
  int x;
  task automatic run;
    #((P)) x = 1;
    #(bump(P)) x = 2;
    #(P:P+1:P+2) x = 3;
    #(time'(P+1)) x = 4;
    #($urandom_range(4, 1)) x = 5;
    x <= #((P)) 6;
    x <= #(bump(P)) 7;
    x <= #(P:P+1:P+2) 8;
  endtask
endmodule
