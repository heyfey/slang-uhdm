// § tfBodyTypedefForcesBegin304
package p;
  function automatic int f(int a);
    typedef int n_t;
    begin : blk
      return a;
    end
  endfunction
endpackage
module top; endmodule
