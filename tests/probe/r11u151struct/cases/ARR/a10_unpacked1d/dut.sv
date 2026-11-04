// ARR: a one-dimensional unpacked array copied whole.
module top(input logic a, output logic o);
  logic pa [2];
  logic pb [2];
  always_comb begin
    pa[0] = a;
    pa[1] = ~a;
    pb = pa;
    o = pb[1];
  end
endmodule
