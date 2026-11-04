// § tfBodyTypedefIsItem304
package p;
  function automatic int g(int a);
    int r;
    begin : blk
      typedef bit [2:0] s_t;
      s_t v;
      v = a[2:0];
      r = v;
    end
    return r;
  endfunction
endpackage
module top; endmodule
