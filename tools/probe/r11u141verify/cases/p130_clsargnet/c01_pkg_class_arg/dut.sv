// § classSpecArgNetNoFile130
// case c01: class specialization argument is a class from a package, imported
package pk;
  class base_c;
  endclass
  class obj #(type T = int);
    T t;
  endclass
endpackage
module top;
  import pk::*;
  obj #(base_c) o1;
endmodule
