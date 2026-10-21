// § clsMethodLocalForeignPkgSpec428
package p;
  typedef int unsigned u_t;
  class box #(type T = int);
  endclass
endpackage
import p::*;
class C;
  task automatic t();
    box #(u_t) b = new;
    fork
      begin
        box #(u_t) d;
      end
    join
  endtask
endclass
module top;
  C c;
endmodule
