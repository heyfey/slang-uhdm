// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 8'h00,
    B = 8'h20
  } t_e;
  localparam t_e D = B;
  function automatic logic f(t_e x);
    return (x != D) && (x != p::A);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
