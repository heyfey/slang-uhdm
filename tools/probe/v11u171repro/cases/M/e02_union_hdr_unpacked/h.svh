package p;
  typedef union packed {
    logic [7:0] w;
    logic [1:0][3:0] n;
  } u_t;
  typedef struct {
    logic [3:0] arr [2];
    u_t u;
  } s_t;
endpackage
