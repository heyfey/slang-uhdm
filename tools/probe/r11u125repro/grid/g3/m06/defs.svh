`define FLOP(Q, D, C = `DEFCLK) \
  always @(posedge C) \
    Q <= D;
