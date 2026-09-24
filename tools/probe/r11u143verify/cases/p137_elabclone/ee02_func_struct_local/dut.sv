// § elabCloneFullNameUnstored137
// case ee02: a sub-module function with a struct-typed local of a module typedef
module sub(input logic [7:0] a, output logic [7:0] y);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pr_t;
  function automatic logic [7:0] swap(input logic [7:0] v);
    pr_t t;
    t = v;
    return {t.lo, t.hi};
  endfunction
  assign y = swap(a);
endmodule
module top(input logic [7:0] a, output logic [7:0] y); sub u(.a(a), .y(y)); endmodule
