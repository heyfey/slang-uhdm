// § assocPromotedBoundAtBracket183: associative class properties keyed by a typedef, int, string and a class in a package class, and a method local
package p;
  typedef bit [2:0] k_t;
  class other; endclass
  class c;
    int pt[k_t];
    int pi[int];
    int ps[string];
    int pc[other];
    function void run();
      int loc[k_t];
      loc[3'd1] = pt[3'd2];
    endfunction
  endclass
endpackage
module top; endmodule
