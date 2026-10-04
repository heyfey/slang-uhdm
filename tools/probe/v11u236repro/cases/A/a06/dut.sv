// § namedCallArgCtx236v — a named call inside a task called from a module process, and a nested named call
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input int a, input int b, output int o);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  int r;
  task automatic t(input int z);
    r = h(.y(z), .x(z));
  endtask
  always_comb begin
    t(a);
  end
  assign o = h(.x(h(.y(a), .x(b))), .y(b)) + r;
endmodule
