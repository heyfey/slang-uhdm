// § macroPathTokOneBuffer186 (a select written with macro arguments inside a generate scope: the pristine mapping stays)
`define CONN(RIF, FIF, LSB, WIDTH) \
  assign  FIF.mask            = RIF.mask[LSB+:WIDTH]; \
  assign  RIF.data[LSB+:WIDTH] = FIF.data;
interface wide_if;
  logic [7:0] mask;
  logic [7:0] data;
endinterface
interface nar_if;
  logic [3:0] mask;
  logic [3:0] data;
endinterface
module m(wide_if w);
  if (1) begin : g_field
    nar_if n();
    `CONN(w, n, 0, 4)
  end
endmodule
module top;
  wide_if w();
  m u(.w(w));
endmodule
