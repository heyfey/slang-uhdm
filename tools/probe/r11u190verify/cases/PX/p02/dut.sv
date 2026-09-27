// § bitSelParenIdxSpan181 (r11u190: parenthesized indices in a continuous assignment, a generate-loop continuous assignment and a function return)
module top(input logic [7:0] a, input logic [2:0] s, output logic y, output logic [1:0] g);
  function automatic logic pick(input logic [7:0] v, input logic [2:0] k); return v[(k)]; endfunction
  assign y = a[(s)] | pick(a, (s));
  for (genvar i = 0; i < 2; i++) begin : G
    assign g[i] = a[((i) * 2)];
  end
endmodule
