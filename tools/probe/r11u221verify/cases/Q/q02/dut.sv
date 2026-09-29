// § genScopeRangeQueryFold216 — $right of a packed-struct variable (no written range) and $left of a packed array of structs in a gen-if
module dut #(parameter bit EN = 1) (output logic [7:0] o1, output logic [7:0] o2);
  typedef struct packed { logic [2:0] a; logic b; } s_t;
  s_t sv;
  s_t [6:3] arr;
  if (EN) begin : g
    assign o1 = $right(sv);
    assign o2 = $left(arr);
  end
endmodule
