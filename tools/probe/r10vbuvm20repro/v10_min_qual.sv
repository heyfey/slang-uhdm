// v10: MINIMAL isolation of the qualified-written class-OOB return-local.
// Package only, no module, no parameter in the range.
package vpx;
  typedef logic signed [7:0] l8_t;
  class Cx;
    extern function vpx::l8_t q();
  endclass
  function vpx::l8_t Cx::q(); q = 'b0; endfunction
endpackage
