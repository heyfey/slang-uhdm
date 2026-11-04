// § tfArgTypedefLastWriter146
module top(output int o);
  typedef enum logic [1:0] {A, B, C} e_t;
  if (1) begin : g
    function automatic int f(e_t x);
      return int'(x);
    endfunction
    assign o = f(B);
  end
endmodule
