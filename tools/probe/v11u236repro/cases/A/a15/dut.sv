// § namedCallArgCtx236v — a named call with constant actuals as an indexed part-select base (a12 alone)
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input logic [15:0] v, output logic [3:0] o);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  assign o = v[h(.x(1), .y(2)) +: 4];
endmodule
