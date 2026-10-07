// § bodyTypeParamChainBorrow278
module dut ( input logic [2:0] i, output logic o );
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  localparam type a_t = s_t;
  localparam type b_t = a_t;
  localparam type c_t = b_t;
  c_t x;
  assign x = i;
  assign o = x.b;
endmodule
