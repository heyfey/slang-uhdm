// § cloneMintParentHomeCall253 (an in-class method, the receiver a class property)
package p;
  class c;
    int seen[string];
    function bit has(string k);
      return seen.exists(k);
    endfunction
  endclass
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
