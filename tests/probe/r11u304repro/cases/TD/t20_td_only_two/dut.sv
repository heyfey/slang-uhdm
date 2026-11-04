// § tfBodyTypedefForcesBegin304
package p;
  int q;
  function automatic void g(int a);
    typedef bit [2:0] s_t;
    typedef bit [3:0] u_t;
    q = a;
  endfunction
endpackage
module top; endmodule
