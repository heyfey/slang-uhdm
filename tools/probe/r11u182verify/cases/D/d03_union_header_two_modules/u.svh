typedef union packed {
  logic [7:0] raw;
  struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } f;
} u_t;
