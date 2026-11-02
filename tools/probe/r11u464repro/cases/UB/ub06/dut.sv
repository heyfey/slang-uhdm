// § unitClsListsSpecBase464 (a typedef of a plain class)
package a;
  class C; int x; endclass
  typedef C D;
endpackage
import a::*;
class test;
  D q;
endclass
module top;
  initial begin test t; t = new; end
endmodule
