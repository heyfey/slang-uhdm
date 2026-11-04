// § streamPartSelLazyName288 — a struct member's and a class property's part-select in a stream, a package parameter part-select operand
package sp4;
  localparam logic [7:0] P = 8'hA5;
endpackage
class cs;
  logic [7:0] r;
  struct packed { logic [7:0] f; } st;
  function logic [7:0] m(); return {<< 2 {r[3:0], st.f[7:4]}}; endfunction
endclass
module top(input logic [7:0] x, output logic [7:0] y, z, w);
  typedef struct packed { logic [7:0] g; } st_t;
  st_t sv;
  assign sv.g = x;
  assign y = {<< 2 {sv.g[3:0], x[7:4]}};
  assign w = {<< 4 {sp4::P[3:0], x[3:0]}};
  cs h;
  initial begin h = new(); z = h.m(); end
endmodule
