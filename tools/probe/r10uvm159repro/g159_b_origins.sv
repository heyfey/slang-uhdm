// r10uvm159 GRID B — ORIGINS.  The same OPERATION-operand fold inside a class
// method, but the folded name comes from a different declaration each row: a
// class localparam / a package-own parameter / an imported package parameter
// with a DECLARED type (int, bit[7:0], a typedef, untyped) / an enum constant
// / a literal / a cast / a $bits / a macro.  MEASUREMENT ONLY.
package q159b_pkg;
  parameter int          QB_INT159   = 21;
  parameter bit [7:0]    QB_BIT159   = 8'd22;
  parameter              QB_UNT159   = 23;
  parameter string       QB_STR159   = "qb";
  typedef logic [5:0]    qb_t159;
  parameter qb_t159      QB_TD159    = 6'd24;
endpackage

package p159b_pkg;
  import uvm_pkg::*;
  import q159b_pkg::*;
  `include "uvm_macros.svh"

  typedef enum int { E159_A = 31, E159_B = 32 } e159_t;

  class c159b extends uvm_object;
    `uvm_object_utils(c159b)
    localparam LP159 = 41;
    int          r159;
    string       s159;
    logic [31:0] v159;

    function new(string name = "c159b");
      super.new(name);
    endfunction

    function void b_rows();
      r159 = QB_INT159 + 1;                   // B_IMP_INT
      r159 = QB_BIT159 + 1;                   // B_IMP_BIT
      r159 = QB_UNT159 + 1;                   // B_IMP_UNTYPED
      r159 = int'(QB_TD159) + 1;              // B_IMP_TYPEDEF (under a cast)
      s159 = {QB_STR159, "x"};                // B_IMP_STRING
      r159 = LP159 + 1;                       // B_CLASS_LOCALPARAM
      r159 = E159_A + 1;                      // B_ENUM_CONST
      r159 = 7 + 1;                           // B_LITERAL
      r159 = int'(QB_UNT159) + 1;             // B_CAST
      r159 = $bits(QB_BIT159) + 1;            // B_BITS
      r159 = `UVM_MAX_STREAMBITS + 1;         // B_MACRO
      r159 = UVM_SETINT + 1;                  // B_UVM_IMPORT (positive control)
    endfunction
  endclass
endpackage

module m159b;
  import p159b_pkg::*;
  c159b h159;
  initial begin
    h159 = new("h159");
    h159.b_rows();
  end
endmodule
