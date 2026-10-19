// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 8'h00,
    B = 8'h20
  } t_e;
  function automatic logic f(t_e x);
    logic r;
    r = 0;
    if (x == A) r = 1;
    case (x)
      B: r = 0;
      default: ;
    endcase
    return r;
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
