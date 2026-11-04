// ARR: array_assign's shape. `pb = pa` in a begin whose direct statements
// write `pa[0][0]`: golden binds the ref to that var_select.
module top(output logic o);
  logic pa [1:0][1:0];
  logic pb [1:0][0:1];
  always_comb begin
    pa[0][0] = 1'b0;
    pa[0][1] = 1'b1;
    pa[1][0] = 1'b1;
    pa[1][1] = 1'b1;
    pb = pa;
    o = pb[0][0];
  end
endmodule
