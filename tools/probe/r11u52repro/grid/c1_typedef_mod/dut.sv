// ROAD C: a MODULE-BODY typedef's range bound.  CompileModule.cpp:653 hands a
// hard Reduce::No into compileDataDeclaration -> compileTypeDef -> element
// compileTypespec.  Four shapes beside the mem_packed_2d one, plus the
// PORT-declaration control (a different road into the same bound).
module dut #(
    parameter int unsigned DATA_SIZE = 64,
    parameter int unsigned DEPTH     = 4,
    parameter int unsigned NDATA     = 2
) (
    input  logic [NDATA-1:0][DATA_SIZE-1:0] wdata,   // PORT holder (control)
    output logic [NDATA-1:0]                o
);
  typedef logic [NDATA-1:0][DATA_SIZE-1:0] mem_t [DEPTH];  // packed 2-D + unpacked
  typedef logic [NDATA-1:0]                pk1_t;          // plain packed
  typedef logic [NDATA-1:0]                up1_t [DEPTH];  // packed + unpacked
  typedef struct packed { logic [NDATA-1:0] f; } st_t;     // struct member bound
  mem_t mem;
  pk1_t p1;
  up1_t u1;
  st_t  s1;
  logic [NDATA-1:0] plain;                                 // net-decl holder
  assign o = p1 | plain | mem[0][0][NDATA-1:0] | u1[0] | s1.f | wdata[0][NDATA-1:0];
endmodule
