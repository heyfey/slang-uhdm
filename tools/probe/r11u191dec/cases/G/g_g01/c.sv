module cmod(output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  function automatic logic [3:0] h(input op_t z); return z.a ^ z.b; endfunction
  localparam op_t R = '{a:4'h5, b:4'h6};
  assign o = h(R);
endmodule
