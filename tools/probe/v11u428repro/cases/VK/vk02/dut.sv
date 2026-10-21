// § clsMethodLocalForeignPkgSpec428
package mgen;
  typedef logic [5:0] six_t;
  class box #(type T = int);
    T v;
  endclass
endpackage
package nuse;
  class C;
    task t();
      mgen::box #(mgen::six_t) b;
    endtask
  endclass
endpackage
module top;
  nuse::C c;
endmodule
