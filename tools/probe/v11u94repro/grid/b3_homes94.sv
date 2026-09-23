// v11u94 break arms: homes of the S law
package p95;
  typedef struct packed { logic [7:0] a; } sub_t;
endpackage
module b3c #(parameter int W = 4) (input logic i, output logic o);
  typedef struct packed { logic [W-1:0] x; logic [W+1:0] y; } ct_t;
  parameter ct_t HP = '{x: 1, y: 2};
  localparam ct_t TP = ct_t'{x: 3, y: 4};
  assign o = i ^ HP.x[0] ^ TP.y[0];
endmodule
module b3 #(parameter int W = 8, parameter N = 3) (input logic i, output logic o1, output logic o2, output logic o3);
  typedef struct packed { p95::sub_t [W-1:0] arr; } t01;
  localparam t01 c01_pkarr = '{arr: 0};
  typedef struct packed { struct packed { logic [W-1:0] q; logic [N+1:0] r; } in; logic [W-2:0] z; } t02;
  localparam t02 c02_anon = '{in: '{q: 1, r: 2}, z: 3};
  typedef enum logic [W-1:0] {A, B} e_t;
  typedef struct packed { e_t e; logic [W-1:0] f; } t03;
  localparam t03 c03_enum = '{e: A, f: 1};
  typedef union packed { logic [W-1:0] a; logic [W-1:0] b; } u_t;
  typedef struct packed { u_t u; logic [W-1:0] g; } t04;
  localparam t04 c04_union = '{u: 0, g: 1};
  localparam t04 c05_ref = c04_union;
  typedef struct packed { logic [N*2-1:0] x; logic [N+N:0] y; } t06;
  localparam t06 c06_untyped = '{x: 1, y: 2};
  b3c u_a (.i(i), .o(o1));
  b3c #(.W(6)) u_b (.i(i), .o(o2));
  b3c #(.W(2)) u_c (.i(i), .o(o3));
endmodule
