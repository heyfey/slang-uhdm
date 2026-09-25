// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top;
  import p::*;
  e_t v;
  function automatic int f(e_t g);
    return int'(g);
  endfunction
endmodule
