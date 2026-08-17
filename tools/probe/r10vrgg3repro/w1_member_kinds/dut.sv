interface itf #(parameter int AW = 16, parameter int NW = 4);
  typedef logic [AW-1:0] word_t;
  typedef struct packed { logic [AW-1:0] f; logic [NW-1:0] g; } st_t;
  logic  [AW-1:0] a;
  wire   [AW-1:0] wn;
  reg    [AW-1:0] rg;
  bit    [AW-1:0] bt;
  byte            by;
  word_t          w;
  st_t            s;
  logic  [AW-1:0] arr2 [NW];
  logic  [AW-1:0][NW-1:0] two_d;
  logic signed [AW-1:0] sg;
  modport mp (input a, w, s);
endinterface
module recv #(parameter int AW = 5, parameter int NW = 2)(itf.mp p[3]);
endmodule
module top;
  itf #(8, 4) arr[3]();
  recv u (.p(arr));
endmodule
