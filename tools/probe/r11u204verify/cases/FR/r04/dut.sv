// § retPkgQualTdNoAlias196: a qualified return in a generate-block function, in a package function returning its own package's typedef qualified, and a qualified enum return
package P;
  typedef logic [3:0] n_t;
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic P::n_t pf(input int a); return a; endfunction
endpackage
module top #(parameter int N = 1) (output wire [31:0] o1, o2, o3);
  if (N > 0) begin : g
    function automatic P::n_t gf(input int a); return a; endfunction
    assign o1 = gf(1);
  end
  function automatic P::e_t ef(input int a); return P::e_t'(a); endfunction
  assign o2 = P::pf(1);
  assign o3 = ef(1);
endmodule
