package pu;
  typedef union packed {
    logic [7:0] raw;
    struct packed {
      logic [3:0] hi;
      logic [3:0] lo;
    } f;
  } u_t;
  typedef struct packed {
    u_t   u;
    logic v;
  } s_t;
endpackage
