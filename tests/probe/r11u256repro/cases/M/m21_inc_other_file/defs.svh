`define conn(FIF, LSB) \
  assign  FIF.read_data[LSB+:4] = x;
