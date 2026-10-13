// § tfBodyTypedefForcesBegin304
package p;
  class c;
    int m;
    function void g(int a);
      typedef bit [2:0] s_t;
      typedef s_t [1:0] w_t;
      m = a;
    endfunction
  endclass
endpackage
module top; endmodule
