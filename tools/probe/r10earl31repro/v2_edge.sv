// r10earl31 VERIFIER arm v2 — the OVER-FIRE hunt: cells where the operation-only
// walk still reaches a part_select but the fold is wrapped in something the
// implementer's grid never put in a RANGE, plus two SCOPES the law claims
// ("every scope") and the grid never leaves the module for.
//
//   w1  d[(pk::DC>1 ? pk::DC : 1)-1:0]   a TERNARY inside the bound
//   w2  d[8'(pk::DC)-1:0]                a CAST inside the bound
//   w3  d[f4(pk::DC)-1:0]                a constant USER FUNCTION CALL in the
//                                        bound (the walk must stop at func_call —
//                                        does golden stamp anyway?)
//   w4  d[((((pk::DC+1)+1)+1)+1)-1:0]    FIVE operations deep
//   w5  package function body            the fold inside the PACKAGE that owns
//                                        the parameter
//   w6  interface body                   a part-select bound inside an INTERFACE
//   w7  $unit-scope wildcard import      read UNQUALIFIED through a
//                                        compilation-unit import
//   w8  d[pk::DC-1:0] in a package-scope function of ANOTHER package
package pk;
  localparam logic [3:0] DC = 4'h2;
  function automatic [31:0] pf(input logic [31:0] w);
    pf = 32'(w[DC-1:0]);                 // w5  inside the owning package
  endfunction
endpackage

package pk2;
  function automatic [31:0] p2f(input logic [31:0] w);
    p2f = 32'(w[pk::DC-1:0]);            // w8  another package's function
  endfunction
endpackage

import pk::*;                            // w7  COMPILATION-UNIT import

interface if2 (input logic [31:0] d);
  logic [31:0] s;
  always_comb begin : iblk
    s = 32'(d[pk::DC-1:0]);              // w6  inside an interface
  end
endinterface

module v2 (
  input  logic [31:0] d,
  output logic [31:0] y
);
  logic [31:0] w1, w2, w3, w4, w7, w9;

  function automatic [3:0] f4(input logic [3:0] a);
    f4 = a;
  endfunction

  always_comb begin : blk
    w1 = 32'(d[(pk::DC > 1 ? pk::DC : 1)-1:0]);   // w1 ternary
    w2 = 32'(d[8'(pk::DC)-1:0]);                  // w2 cast
    w3 = 32'(d[f4(pk::DC)-1:0]);                  // w3 user function call
    w4 = 32'(d[((((pk::DC+1)+1)+1)+1)-1:0]);      // w4 five ops deep
    w7 = 32'(d[DC-1:0]);                          // w7 $unit import, unqualified
  end

  if2 ii (.d(d));
  assign w9 = pk::pf(d) ^ pk2::p2f(d) ^ ii.s;
  assign y = w1 ^ w2 ^ w3 ^ w4 ^ w7 ^ w9;
endmodule
