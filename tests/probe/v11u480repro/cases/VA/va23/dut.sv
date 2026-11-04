// § fixArrLocalNamedAggElemTs480 (enum local array in a function of a module with a port)
module sub(input logic [1:0] i, output logic [1:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  function automatic logic [1:0] f(input logic [1:0] n);
    e_t arr[2];
    arr[0] = e_t'(n);
    arr[1] = arr[0];
    return arr[1];
  endfunction
  assign o = f(i);
endmodule
module top(input logic [1:0] i, output logic [1:0] o);
  sub s(.i(i), .o(o));
endmodule
