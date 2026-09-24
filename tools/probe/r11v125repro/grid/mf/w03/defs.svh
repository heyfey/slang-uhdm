`define INV(x) ~x
`define BLK(n) \
  logic [3:0] n; \
  assign n = `INV(a);
