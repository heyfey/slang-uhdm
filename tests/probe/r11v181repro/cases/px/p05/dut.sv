// § bitSelParenIdxSpan181 (v11u181 break: parenthesized index in a class method, on a queue and a dynamic array, and on a struct-member path)
typedef struct packed { logic [7:0] f; } s_t;
module top;
  class C;
    int q[$];
    int d[];
    function int g(int k);
      return q[(k)] + d[(k+1)];
    endfunction
  endclass
  s_t s;
  logic y, z;
  int i;
  initial begin
    y = s.f[(i)];
    z = s[(i)];
  end
endmodule
