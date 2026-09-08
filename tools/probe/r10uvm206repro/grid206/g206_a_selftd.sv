// r10uvm206 grid arm A — THE CLASS KEY ITSELF.
// A file-scope `import pa206::*` must publish, at the DESIGN's typespec
// listing, one entry per package class that a typedef named — under the
// CLASS's name, carrying THAT TYPEDEF's name.  Four context kinds in one arm:
//   ca206_self   a class with its own self-typedef            -> listed
//   ca206_param  a parameterized class with a self-typedef    -> listed
//   ca206_none   a class no typedef ever names                -> NOT listed
//   ca206_other  named only by ANOTHER class's typedef        -> listed
package pa206;
  class ca206_none;
    int n;
  endclass
  class ca206_other;
    int o;
  endclass
  class ca206_self;
    typedef ca206_self this_type;
    typedef ca206_other other_type;
    int s;
  endclass
  class ca206_param #(type T = int);
    typedef ca206_param #(T) this_type;
    T p;
  endclass
  typedef int ta206_plain;
endpackage

import pa206::*;

module ga206;
  ca206_self  h0;
  ca206_param #(int) h1;
  ca206_none  h2;
  ta206_plain w0;
endmodule
