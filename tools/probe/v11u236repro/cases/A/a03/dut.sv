// § namedCallArgFormalTs236 — named calls to a package function, and a function declared after its caller
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
  function automatic int ph(file_t x, byte_t y);
    return x * y;
  endfunction
endpackage
module top (input int a, input int b, output int o, output int o2);
  assign o = p::ph(.y(b), .x(a));
  assign o2 = late(.k(a), .j(b));
  function automatic int late(p::file_t j, p::byte_t k);
    return j | k;
  endfunction
endmodule
