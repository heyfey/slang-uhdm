// § enumQualDefaultDefSpan147
package pk;
  typedef enum integer {N0 = 0, N1 = 1} e_t;
endpackage
module top #(parameter pk::e_t P = pk::N0) (output logic o);
  assign o = (P == pk::N1);
endmodule
