// r10uvm178 ARM D — THE CONTROL-DEPTH DIMENSION.  MEASUREMENT ONLY.
// The uvm site reads the parameter at depth THREE (`for` / `for` / `if`), so
// the arm walks depth 0..4 in the parameter's HOME package and, in the same
// order, in a WILDCARD-IMPORT clone of it.  A class method in each package is
// the fifth reader, because a class body reaches this code through a different
// Surelog entry point.

package D_home178;
  parameter bit [31:0] dPoly178 = 32'h04C1_1DB6;

  function automatic bit [31:0] d0_178(input bit [31:0] a);
    bit [31:0] r;
    r = a ^ dPoly178;                                // depth 0
    return r;
  endfunction

  function automatic bit [31:0] d1_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    if (a[0]) r ^= dPoly178;                         // depth 1
    return r;
  endfunction

  function automatic bit [31:0] d2_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    for (int i = 0; i < 4; i++)
      if (r[31]) r ^= dPoly178;                      // depth 2
    return r;
  endfunction

  function automatic bit [31:0] d3_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 8; j++) begin
        if (r[31] ^ a[j]) begin
          r ^= dPoly178;                             // depth 3 — the uvm shape
          r[0] = 1'b1;
        end
      end
    end
    return r;
  endfunction

  function automatic bit [31:0] d4_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    while (r[1]) begin
      case (r[3:2])
        2'b01: begin
          for (int k = 0; k < 2; k++) r ^= dPoly178; // depth 4
        end
        default: r = r >> 1;
      endcase
    end
    return r;
  endfunction

  class DcHome178;
    function bit [31:0] m_178(input bit [31:0] a);
      bit [31:0] r;
      r = a;
      if (a[2]) r ^= dPoly178;                       // class method, home pkg
      return r;
    endfunction
  endclass
endpackage

package D_clone178;
  import D_home178::*;

  function automatic bit [31:0] e0_178(input bit [31:0] a);
    bit [31:0] r;
    r = a ^ dPoly178;
    return r;
  endfunction

  function automatic bit [31:0] e1_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    if (a[0]) r ^= dPoly178;
    return r;
  endfunction

  function automatic bit [31:0] e2_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    for (int i = 0; i < 4; i++)
      if (r[31]) r ^= dPoly178;
    return r;
  endfunction

  function automatic bit [31:0] e3_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 8; j++) begin
        if (r[31] ^ a[j]) begin
          r ^= dPoly178;
          r[0] = 1'b1;
        end
      end
    end
    return r;
  endfunction

  function automatic bit [31:0] e4_178(input bit [31:0] a);
    bit [31:0] r;
    r = a;
    while (r[1]) begin
      case (r[3:2])
        2'b01: begin
          for (int k = 0; k < 2; k++) r ^= dPoly178;
        end
        default: r = r >> 1;
      endcase
    end
    return r;
  endfunction

  class DcClone178;
    function bit [31:0] n_178(input bit [31:0] a);
      bit [31:0] r;
      r = a;
      if (a[2]) r ^= dPoly178;
      return r;
    endfunction
  endclass
endpackage

module m178d (input logic clk, output bit [31:0] z0, z1, z2, z3, z4, w3);
  import D_home178::*;
  import D_clone178::*;
  assign z0 = d0_178(32'd1);
  assign z1 = d1_178(32'd3);
  assign z2 = d2_178(32'd5);
  assign z3 = d3_178(32'd7);
  assign z4 = d4_178(32'd9);
  assign w3 = e3_178(32'd11);
endmodule
