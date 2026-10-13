// § tfBodyTypedefForcesBegin304
package p;
  function automatic int g(int a);
    typedef bit [2:0] s_t;
    return a + 1;
  endfunction
endpackage
module top; endmodule
