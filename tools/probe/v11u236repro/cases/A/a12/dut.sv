// § namedCallArgCtx236v — named calls with constant actuals as a part-select base, an indexed width, a replication count and a parameter default
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; #(parameter int P = 2) (input logic [15:0] v, output logic [3:0] o, output logic [7:0] o2);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  localparam int L = h(.y(1), .x(P));
  assign o = v[h(.x(1), .y(2)) +: 4];
  assign o2 = {h(.x(1), .y(1)){v[L]}};
endmodule
