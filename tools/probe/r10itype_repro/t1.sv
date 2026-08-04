interface ia #(
  parameter int PA = 1
);
endinterface

interface ib;
  logic q;
endinterface

interface ic (
  ia  aa,
  ib  bb,
  input logic clk
);
  logic z;
endinterface

module top();

logic c;
ia #(5) i_a();
ib      i_b();
ic      u_c (i_a, i_b, c);

endmodule
