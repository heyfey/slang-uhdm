// § tfArgTypedefLastWriter146
package p;
  typedef enum logic [2:0] {A, B, C} e_t;
  function automatic logic f(e_t x); return x == A; endfunction
  task automatic t(input logic a,
                   input e_t y); endtask
endpackage
module top(output logic o);
  import p::*;
  assign o = f(B);
endmodule
