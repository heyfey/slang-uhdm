// v159 VERIFIER ARM B — FOLDED-CONSTANT FACES.  Every declaration face of the
// folded name, read as an OPERATION operand inside a class method of a package
// that materialises a wildcard import.  MEASUREMENT ONLY.
package vq159b_pkg;
  parameter int          VB_INT   = 11;
  parameter integer      VB_ITG   = 12;
  parameter bit [7:0]    VB_BIT   = 8'd13;
  parameter logic [3:0]  VB_LOG   = 4'd14;
  parameter              VB_UNT   = 15;
  parameter string       VB_STR   = "vb";
  parameter real         VB_REAL  = 1.5;
  parameter              VB_SIZED = 8'd16;
  parameter              VB_UNSZ  = 'h17;
  typedef logic [5:0]    vb_t;
  parameter vb_t         VB_TD    = 6'd18;
  parameter int          VB_CHAIN = VB_INT + 1;
  typedef enum int { VB_E0 = 21, VB_E1 = 22 } vb_e;
  parameter int          VB_CAST  = int'(8'd23);
  parameter int          VB_BITS  = $bits(vb_t);
  parameter int          VB_CLOG  = $clog2(64);
endpackage

`define VB_MACRO 31

package vp159b_pkg;
  import vq159b_pkg::*;

  parameter int VB_OWN = 41;          // the package's OWN parameter (control)

  class vc159b #(int PCLS = 51);
    localparam LP = 61;
    int    r;
    real   rr;
    string s;
    logic [63:0] v;

    function void b_rows();
      r  = VB_INT   + 1;   // B_INT
      r  = VB_ITG   + 1;   // B_INTEGER
      r  = VB_BIT   + 1;   // B_BIT8
      r  = VB_LOG   + 1;   // B_LOGIC4
      r  = VB_UNT   + 1;   // B_UNTYPED
      s  = {VB_STR, "x"};  // B_STRING
      rr = VB_REAL  + 1.0; // B_REAL
      r  = VB_SIZED + 1;   // B_SIZED_LITERAL_PARAM
      r  = VB_UNSZ  + 1;   // B_UNSIZED_LITERAL_PARAM
      r  = int'(VB_TD) + 1;// B_TYPEDEF
      r  = VB_CHAIN + 1;   // B_PARAM_OF_PARAM
      r  = VB_E0    + 1;   // B_ENUM_CONST
      r  = VB_CAST  + 1;   // B_CAST_PARAM
      r  = VB_BITS  + 1;   // B_BITS_PARAM
      r  = VB_CLOG  + 1;   // B_CLOG2_PARAM
      r  = `VB_MACRO + 1;  // B_MACRO
      r  = 71 + 1;         // B_LITERAL
      r  = 8'd72 + 1;      // B_SIZED_LITERAL
      r  = VB_OWN   + 1;   // B_PKG_OWN (negative control)
      r  = LP       + 1;   // B_CLASS_LOCALPARAM (negative control)
      r  = PCLS     + 1;   // B_CLASS_PARAMETER (negative control)
      r  = $bits(VB_BIT) + 1;   // B_BITS_OF_IMPORT
      r  = $clog2(VB_INT) + 1;  // B_CLOG2_OF_IMPORT
      r  = int'(VB_INT) + 1;    // B_CAST_OF_IMPORT
      v  = 64'(VB_INT) + 1;     // B_SIZECAST_OF_IMPORT
    endfunction
  endclass

  // a type parameter face
  class vc159bt #(type T = int);
    int r;
    function void bt_rows();
      r = $bits(T) + VB_INT;
    endfunction
  endclass
endpackage

module vm159b;
  import vp159b_pkg::*;
  vc159b #(52) h;
  vc159bt #(logic [7:0]) ht;
  initial begin
    h = new();
    ht = new();
    h.b_rows();
    ht.bt_rows();
  end
endmodule
