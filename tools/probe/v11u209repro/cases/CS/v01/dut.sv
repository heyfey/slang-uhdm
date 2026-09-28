// § classTdPkgEnumMemberShares209: a package struct typedef with a package enum member used as a module function formal
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef struct packed { e_t k; logic [3:0] d; } s_t;
endpackage
module top(input p::s_t si, output logic [3:0] y);
  function automatic logic [3:0] f(p::s_t x);
    return (x.k == p::B) ? x.d : 4'd0;
  endfunction
  assign y = f(si);
endmodule
