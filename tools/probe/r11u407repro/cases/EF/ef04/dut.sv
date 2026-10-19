// § pkgRetEnumOperandFold407
module top(input logic [7:0] i, output logic o);
  typedef enum logic [7:0] {
    A = 'b000_00000,
    B = 'b001_00000
  } t_e;
  function automatic logic f(t_e x);
    return (x != A);
  endfunction
  assign o = f(t_e'(i));
endmodule
