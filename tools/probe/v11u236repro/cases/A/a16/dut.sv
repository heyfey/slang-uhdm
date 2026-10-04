// § namedCallArgCtx236v — a named call with constant actuals as a replication count and a bit-select index (a12 alone)
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input logic [15:0] v, output logic [7:0] o2, output logic o3);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  assign o2 = {h(.x(1), .y(1)){v[3]}};
  assign o3 = v[h(.y(3), .x(1))];
endmodule
