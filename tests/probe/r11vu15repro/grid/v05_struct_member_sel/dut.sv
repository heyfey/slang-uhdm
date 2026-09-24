module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  typedef struct packed { logic [31:0] hi; logic [31:0] lo; } st_t;
  st_t p;
  always_comb begin : blk
    p        = a;
    p.lo[3:0] = b[3:0];
    o        = p;
  end
endmodule
