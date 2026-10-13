// § tfBodyTypedefIsItem304
package p;
  function automatic int f(int a);
    typedef logic [3:0] n_t;
    begin
      n_t v;
      v = a;
    end
    return a + 1;
  endfunction
endpackage
module top; endmodule
