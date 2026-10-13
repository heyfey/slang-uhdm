// § tfBodyTypedefIsItem304
`define TD typedef bit [2:0] s_t;
package p;
  function automatic int g(int a);
    `TD
    s_t v;
    v = a[2:0];
    return v;
  endfunction
endpackage
module top; endmodule
