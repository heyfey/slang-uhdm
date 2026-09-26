package pa;
  typedef struct packed {
    logic [1:0] a;
    logic [1:0] b;
  } in_t;
  typedef struct packed {
    in_t  x;
    logic y;
  } s_t;
endpackage
