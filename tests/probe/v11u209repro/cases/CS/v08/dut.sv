// § classTdPkgEnumMemberShares209: an unpacked-array formal of a struct typedef with a package enum member
package p;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { e_t k; logic [1:0] d; } s_t;
endpackage
module top(input p::s_t si0, input p::s_t si1, output logic [1:0] y);
  p::s_t arr [2];
  assign arr[0] = si0;
  assign arr[1] = si1;
  function automatic logic [1:0] pick(input p::s_t a [2]);
    return a[1].d;
  endfunction
  assign y = pick(arr);
endmodule
