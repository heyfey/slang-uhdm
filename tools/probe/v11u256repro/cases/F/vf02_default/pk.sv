// § patLitFormFileAtRef256 (a default: pattern key)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  typedef enum logic [3:0] {MA = 4'h1, MB = 4'h5} md_e;
  typedef struct packed { logic [3:0] zero1; logic [3:0] datasize; logic [11:0] dataaddr; } hartinfo_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t inner; logic [3:0] c; } out_t;
  typedef struct packed { md_e m; logic [3:0] c; } me_t;
endpackage
