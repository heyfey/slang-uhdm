// § modTfLvTrailIdxNamesByChain312
typedef struct { int idx[4]; } us_t;
module top; us_t s; task t(input int i); s.idx[i + 1] = 0; endtask endmodule
