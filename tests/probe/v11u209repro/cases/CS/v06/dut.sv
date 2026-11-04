// § classTdPkgEnumMemberShares209: a struct typedef with a package enum member as a task formal and a function local
package p;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { e_t k; logic [1:0] d; } s_t;
endpackage
module top(input logic clk, input p::s_t si, output logic [1:0] y);
  function automatic logic [1:0] g;
    input p::s_t z;
    p::s_t loc;
    loc = z;
    g = (loc.k == p::A) ? loc.d : 2'd3;
  endfunction
  always_ff @(posedge clk) y <= g(si);
endmodule
