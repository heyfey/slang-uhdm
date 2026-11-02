// § procAsgRhsPkgFoldTs471
// class in a package with a method assigning an imported parameter; module process too
package a;
  parameter int PA = 12;
endpackage
package k;
  import a::*;
  class C;
    int m;
    function void set(); m = PA; endfunction
  endclass
endpackage
module top(output int y);
  import a::*;
  initial y = PA;
endmodule
