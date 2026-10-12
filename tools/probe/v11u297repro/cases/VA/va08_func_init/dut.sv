// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o);
  function automatic t_t mk(input logic v);
    mk = {2'b10, v};
  endfunction
  var t_t x = mk(1'b1);
  assign o = x;
endmodule
