package pk;
  typedef enum logic [1:0] { A0=2'b00, A1=2'b01 } mode_e;
  typedef struct packed { logic lock; mode_e mode; } withenum_t;
  typedef struct packed { logic lock; logic mode; } alllogic_t;
endpackage

module dut();
  import pk::*;
  typedef struct packed { logic lock; mode_e mode; } loc_withenum_t;
  typedef struct packed { logic lock; logic mode; } loc_alllogic_t;

  // pkg-qualified, all-logic
  pk::alllogic_t pq_all_drv [4];
  assign pq_all_drv[0].lock = 1'b0;
  pk::alllogic_t pq_all_und [4];

  // pkg-qualified, with enum member
  pk::withenum_t pq_enum_drv [4];
  assign pq_enum_drv[0].lock = 1'b0;
  pk::withenum_t pq_enum_und [4];

  // imported bare name, all-logic
  alllogic_t im_all_drv [4];
  assign im_all_drv[0].lock = 1'b0;
  alllogic_t im_all_und [4];

  // module-local typedef, with enum member
  loc_withenum_t lo_enum_drv [4];
  assign lo_enum_drv[0].lock = 1'b0;
  loc_withenum_t lo_enum_und [4];

  // module-local typedef, all-logic
  loc_alllogic_t lo_all_drv [4];
  assign lo_all_drv[0].lock = 1'b0;
  loc_alllogic_t lo_all_und [4];
endmodule
