// § fixArrLocalNamedAggElemTs480 (packed union local array with an initializer)
module top;
  typedef union packed { logic [7:0] b; logic [7:0] c; } u_t;
  function automatic logic [7:0] f(input logic [7:0] n);
    u_t acc[2] = '{default: 8'h0};
    acc[0].b = n;
    return acc[0].c;
  endfunction
  logic [7:0] x;
  assign x = f(8'h5);
endmodule
