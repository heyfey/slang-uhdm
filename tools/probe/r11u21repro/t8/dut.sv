// t8 — THE BAIL.  One member is written from a value the producer's assembler
// cannot reduce, so golden's elaborated base Rhs stays a struct_var and the
// member read is NOT sliced.
package pk;
  typedef enum { U0, U1 } u_t;                 // untyped enum: never folds
  typedef struct packed { int unsigned a; logic [1:0] z; } c_t;
  function automatic c_t mk();
    c_t c;
    c.a = 3;
    c.z = 2'(U1);
    return c;
  endfunction
  localparam c_t C = mk();
endpackage

module dut #(
    parameter pk::c_t CFG = pk::C
) (output logic o);
  localparam int BA = CFG.a;
  assign o = ^{BA[0]};
endmodule
