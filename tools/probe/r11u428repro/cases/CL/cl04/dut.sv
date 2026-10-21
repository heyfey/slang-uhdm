// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
    T v;
  endclass
endpackage
module top;
  import p::*;
  class C;
    task t();
      begin
        box #(shortint) b;
      end
    endtask
  endclass
  C c;
endmodule
