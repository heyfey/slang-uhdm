// r10uvm206 grid arm B — THE BY-OBJECT DEDUP, BOTH DIRECTIONS.
// A PACKAGE typedef whose target is a class is the object that class's key
// holds too.  The union keeps the ALPHABETICALLY FIRST of the two keys:
//   aa206_early  (typedef name < class name cb206_late)  -> stays at the TYPEDEF key
//   zz206_late   (typedef name > class name cb206_mid)   -> moves to the CLASS key
// The two typedefs of cb206_two prove FIRST-WRITER-WINS among package
// typedefs: `m206_first` is alphabetically first and is the one the class key
// carries, `n206_second` keeps its own key.
package pb206;
  class cb206_late #(type T = int);
    T l;
  endclass
  class cb206_mid #(type T = int);
    T m;
  endclass
  class cb206_two #(type T = int);
    T t;
  endclass
  typedef cb206_late #(int) aa206_early;
  typedef cb206_mid  #(int) zz206_late;
  typedef cb206_two  #(int) m206_first;
  typedef cb206_two  #(byte) n206_second;
endpackage

import pb206::*;

module gb206;
  aa206_early e0;
  zz206_late  e1;
  m206_first  e2;
  n206_second e3;
endmodule
