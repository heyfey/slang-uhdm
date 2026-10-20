// § classWildcardIdxRefTs414
package p;
class Packet; int x; endclass
class Driver;
  Packet q [*];
  int m [*];
  function void f(); m[3] = 1; endfunction
endclass
endpackage
module test;
endmodule
