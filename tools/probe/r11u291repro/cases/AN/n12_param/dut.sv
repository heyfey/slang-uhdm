// § anonAggMemberChainName291
typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
module dut(output logic [3:0] o);
  localparam t_t P = 4'b1010;
  assign o = P;
endmodule
