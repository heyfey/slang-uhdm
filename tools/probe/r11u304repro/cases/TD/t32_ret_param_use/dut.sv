// § tfBodyTypedefForcesBegin304
package p;
  parameter int P = 3;
  function automatic int g(int a);
    typedef bit [P-1:0] s_t;
    return s_t'(a) + P;
  endfunction
endpackage
module top; endmodule
