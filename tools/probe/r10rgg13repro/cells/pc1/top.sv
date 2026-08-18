// r10rgg13 POSITIVE CONTROL — § genLpPaCallArgCopy13 in miniature.
// A MULTIDIMENSIONAL localparam initialised by a call whose only argument is a
// bare parameter name, with an INT formal, instantiated once per override
// encoding.  Golden's argument is a verbatim COPY of P's own param_assign Rhs
// (HEX:03 ct 5 for `#(.P(8'h03))`); the base binary mints UINT:3 ct 9.
module mid #(
  parameter int P = 8'h07
)(
  output logic o
);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list;
    list = '0;
    list[0] = 16'(n);
    return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule

module top;
  logic o1, o2, o3, o4;
  mid #(.P(2))       u_dec (.o(o1));
  mid #(.P(8'h03))   u_hex (.o(o2));
  mid #(.P(4'b0101)) u_bin (.o(o3));
  mid                u_def (.o(o4));
endmodule
