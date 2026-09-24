// § packedArrTdElemRefName137
// case pd04: a packed-array typedef over an enum declared inside a generate block
module top(output logic [3:0] o);
  if (1) begin : g
    typedef enum logic [1:0] {X0, X1, X2} k_t;
    typedef k_t [1:0] ka_t;
    ka_t v;
    assign v = {X1, X2};
    assign o = v;
  end
endmodule
