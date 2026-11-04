// § tfBodyTypedefIsItem304
package p;
  class c;
    extern function void g();
  endclass
  function void c::g();
    typedef bit [2:0] s_t;
    s_t v;
    v = 3'b0;
  endfunction
endpackage
module top; endmodule
