// v97_c3 — ONE parameterized class, TWO typedefs of the SAME target, TWO live
// specializations: the group is {aa x2, bb x2}; golden is {aa base, bb clone}.
package p97c3;
  class tgt97c3;
    int q;
  endclass
  class gen97c3 #(type T = int);
    typedef tgt97c3 aa97c3;
    typedef tgt97c3 bb97c3;
    aa97c3 h_a;
    bb97c3 h_b;
    T v;
    function void use_b(bb97c3 z); h_b = z; endfunction
  endclass
  class si97c3 extends gen97c3 #(int);
    function void f(bb97c3 p); h_b = p; endfunction
  endclass
  class sb97c3 extends gen97c3 #(byte);
    function void f(bb97c3 p); h_b = p; endfunction
  endclass
endpackage
module top97c3;
endmodule
