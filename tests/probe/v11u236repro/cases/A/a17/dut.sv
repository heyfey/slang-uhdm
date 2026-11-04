// § namedCallArgCtx236v — a named call with constant actuals as a part-select bound and as an indexed part-select width
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input logic [15:0] v, output logic [3:0] o, output logic [2:0] o2);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  assign o = v[h(.x(2), .y(1)):0];
  assign o2 = v[4 +: h(.x(1), .y(2))];
endmodule
