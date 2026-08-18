// r10rgg13 MUST-NOT-MOVE — gate clause (2), a NON-INTEGER formal.  Golden's copy
// wears the PARAMETER's `int_typespec` where our formal-ts law binds the
// formal's `bit_typespec`; the value copy alone cannot make the row right and
// retargeting the typespec is what the func_upto fence forbids, so this arm
// stays exactly where it was.
module mid #(
  parameter int P = 8'h07
)(
  output logic o
);
  function automatic bit [P-1:0][15:0] flp(bit [7:0] n);
    bit [P-1:0][15:0] list;
    list = '0;
    list[0] = 16'(n);
    return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule

module top;
  logic o1, o2;
  mid #(.P(2))     u_dec (.o(o1));
  mid #(.P(8'h03)) u_hex (.o(o2));
endmodule
