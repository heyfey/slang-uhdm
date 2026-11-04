// § bitSelParenIdxSpan181 (v11u181 break: parenthesized index in a case subject, a case item, a return, a for condition, a $display)
module top(input logic [7:0] a, input logic [2:0] i, output logic y);
  function automatic logic f(logic [7:0] v, int k);
    for (int j = 0; j < v[(k)]; j++) k++;
    return v[(k-1)];
  endfunction
  always_comb begin
    case (a[(i)])
      a[(0)]: y = f(a, i);
      default: y = 0;
    endcase
    $display("%b", a[(i)]);
  end
endmodule
